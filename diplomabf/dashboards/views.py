from django.shortcuts import render, redirect
from django.http import FileResponse
from django.core.files.storage import default_storage
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from diplomas.models import Diploma, Institution, VerificationLog
from accounts.models import CustomUser
from django.db.models import Count, Sum
from diplomas.blockchain_utils import get_algod_client, get_treasury_account, get_balance
import random
import string

@login_required
def dashboard_router(request):
    """Redirects the user to the appropriate dashboard based on their role."""
    role = request.user.role
    
    if role == 'admin':
        return admin_dashboard(request)
    elif role == 'institution':
        return institution_dashboard(request)
    elif role == 'recruiter':
        return recruiter_dashboard(request)
    else:
        return student_dashboard(request)

@login_required
def student_dashboard(request):
    if request.user.role != 'student':
        return dashboard_router(request)
        
    all_diplomas = Diploma.objects.filter(student_email=request.user.email).order_by('-graduation_date')
    recent_diplomas = all_diplomas[:3]
    
    all_verifications = VerificationLog.objects.filter(diploma__student_email=request.user.email).order_by('-verified_at')
    recent_verifications = all_verifications[:5]
    
    # Calculate Stats
    stats = {
        'total': all_diplomas.count(),
        'blockchain_verified': all_diplomas.filter(blockchain_tx_id__isnull=False).exclude(blockchain_tx_id='').count(),
        'total_verifications': all_verifications.count(),
        'last_verification': all_verifications.first().verified_at if all_verifications.exists() else None,
    }
    
    return render(request, 'dashboards/student.html', {
        'diplomas': recent_diplomas,
        'verifications': recent_verifications,
        'stats': stats
    })

@login_required
def student_diplomas(request):
    """View to list all diplomas of a student with search."""
    if request.user.role != 'student':
        return redirect('dashboard')
        
    query = request.GET.get('q', '')
    diplomas = Diploma.objects.filter(student_email=request.user.email).order_by('-graduation_date')
    
    if query:
        from django.db.models import Q
        diplomas = diplomas.filter(
            Q(degree_name__icontains=query) |
            Q(institution__name__icontains=query) |
            Q(unique_identifier__icontains=query)
        )
        
    return render(request, 'dashboards/student_diplomas.html', {
        'diplomas': diplomas,
        'query': query
    })

@login_required
def student_verifications(request):
    """View to list all recruiters who verified the student's diplomas."""
    if request.user.role != 'student':
        return redirect('dashboard')
        
    verifications = VerificationLog.objects.filter(diploma__student_email=request.user.email).order_by('-verified_at')
    return render(request, 'dashboards/student_verifications.html', {
        'verifications': verifications
    })

@login_required
def student_diploma_download(request, diploma_id):
    """View for students to download their own diploma PDF."""
    try:
        diploma = Diploma.objects.get(id=diploma_id, student_email=request.user.email)
    except Diploma.DoesNotExist:
        messages.error(request, "Diplôme introuvable ou accès refusé.")
        return redirect('dashboard_student')

    if not diploma.pdf_file or not diploma.pdf_file.name:
        messages.error(request, "Le fichier PDF est indisponible.")
        return redirect('dashboard_student')

    return FileResponse(diploma.pdf_file.open('rb'), as_attachment=True, filename=f"Diplome_{diploma.unique_identifier}.pdf")

@login_required
def recruiter_dashboard(request):
    """Recruiter dashboard view."""
    # Fetch diplomas verified by THIS recruiter
    my_verifications = VerificationLog.objects.filter(recruiter=request.user).order_by('-verified_at')

    return render(request, 'dashboards/recruiter.html', {
        'verifications': my_verifications
    })

@login_required
def institution_dashboard(request):
    try:
        inst = Institution.objects.get(name=request.user.institution_name)
    except Institution.DoesNotExist:
        inst = None
        
    diplomas = Diploma.objects.filter(institution=inst).order_by('-created_at') if inst else []
    recent_diplomas = diplomas[:5] if inst else []
    
    # Calculate Stats
    stats = {
        'total': diplomas.count() if inst else 0,
        'verifications': VerificationLog.objects.filter(diploma__institution=inst).count() if inst else 0,
        'revoked': diplomas.filter(status='revoked').count() if inst else 0,
        'pending': diplomas.filter(status='pending').count() if inst else 0,
    }
    
    # Fetch Algorand Balance
    balance = 0
    if inst and inst.blockchain_address:
        try:
            client = get_algod_client()
            account_info = client.account_info(inst.blockchain_address)
            balance = account_info.get('amount', 0) / 1_000_000
        except Exception:
            balance = "Erreur"

    return render(request, 'dashboards/institution.html', {
        'institution': inst,
        'diplomas': recent_diplomas,
        'stats': stats,
        'balance': balance
    })

@login_required
def institution_register(request):
    """View to show all diplomas of an institution."""
    if request.user.role != 'institution':
        return redirect('dashboard')
    
    try:
        inst = Institution.objects.get(name=request.user.institution_name)
    except Institution.DoesNotExist:
        return redirect('dashboard')
        
    diplomas = Diploma.objects.filter(institution=inst).order_by('-graduation_date')
    return render(request, 'dashboards/institution_register.html', {
        'diplomas': diplomas
    })

@login_required
def search_diplomas(request):
    """Search within an institution's diplomas."""
    if request.user.role != 'institution':
        return redirect('dashboard')
        
    query = request.GET.get('q', '')
    results = []
    results_count = 0
    
    if query:
        try:
            inst = Institution.objects.get(name=request.user.institution_name)
            from django.db.models import Q
            results = Diploma.objects.filter(
                Q(student_first_name__icontains=query) |
                Q(student_last_name__icontains=query) |
                Q(student_id_number__icontains=query) |
                Q(unique_identifier__icontains=query),
                institution=inst
            )
            results_count = results.count()
        except Institution.DoesNotExist:
            pass

    return render(request, 'dashboards/search_diplomas.html', {
        'query': query,
        'results': results,
        'results_count': results_count
    })

@login_required
def admin_dashboard(request):
    if request.user.role != 'admin':
        return dashboard_router(request)
        
    # User Counts
    counts = CustomUser.objects.values('role').annotate(total=Count('id'))
    user_stats = {c['role']: c['total'] for c in counts}
    
    # Blockchain / Treasury
    _, treso_addr, _ = get_treasury_account()
    balance = get_balance(treso_addr) if treso_addr else 0
    
    stats = {
        'total_users': CustomUser.objects.count(),
        'total_institutions': Institution.objects.count(),
        'total_diplomas': Diploma.objects.count(),
        'verified_diplomas': Diploma.objects.filter(blockchain_tx_id__isnull=False).exclude(blockchain_tx_id='').count(),
        'student_count': user_stats.get('student', 0),
        'uni_count': user_stats.get('institution', 0),
        'recruiter_count': user_stats.get('recruiter', 0),
        'admin_count': user_stats.get('admin', 0),
        'treasury_balance': balance
    }
    
    recent_diplomas = Diploma.objects.all().order_by('-created_at')[:5]
    
    return render(request, 'dashboards/admin.html', {
        'stats': stats,
        'recent_diplomas': recent_diplomas
    })

@login_required
def admin_manage_users(request, role):
    if request.user.role != 'admin':
        return redirect('dashboard')
        
    users = CustomUser.objects.filter(role=role).order_by('-date_joined')
    role_display = {
        'admin': 'Administrateurs',
        'institution': 'Universités',
        'student': 'Étudiants',
        'recruiter': 'Recruteurs'
    }.get(role, 'Utilisateurs')
    
    return render(request, 'dashboards/admin_users_list.html', {
        'users': users,
        'role_key': role,
        'role_display': role_display
    })

@login_required
def admin_user_detail(request, user_id):
    if request.user.role != 'admin':
        return redirect('dashboard')
        
    user = CustomUser.objects.get(id=user_id)
    diplomas = []
    verifications = []
    
    if user.role == 'student':
        diplomas = Diploma.objects.filter(student_email=user.email).order_by('-graduation_date')
    elif user.role == 'recruiter':
        verifications = VerificationLog.objects.filter(recruiter=user).order_by('-verified_at')
    elif user.role == 'institution':
        diplomas = Diploma.objects.filter(institution__name=user.institution_name).order_by('-created_at')
        
    return render(request, 'dashboards/admin_user_detail.html', {
        'target_user': user,
        'diplomas': diplomas,
        'verifications': verifications
    })

@login_required
def admin_toggle_user_status(request, user_id):
    if request.user.role != 'admin':
        return redirect('dashboard')
    
    user = CustomUser.objects.get(id=user_id)
    if user == request.user:
        messages.error(request, "Vous ne pouvez pas désactiver votre propre compte.")
        return redirect(request.META.get('HTTP_REFERER', 'dashboard'))
        
    user.is_active = not user.is_active
    user.save()
    
    status_msg = "activé" if user.is_active else "désactivé"
    messages.success(request, f"Le compte de {user.username} a été {status_msg}.")
    return redirect(request.META.get('HTTP_REFERER', 'dashboard'))

@login_required
def admin_reset_password(request, user_id):
    if request.user.role != 'admin':
        return redirect('dashboard')
        
    user = CustomUser.objects.get(id=user_id)
    if user == request.user:
        messages.error(request, "Utilisez la page 'Profil' pour changer votre mot de passe.")
        return redirect(request.META.get('HTTP_REFERER', 'dashboard'))
        
    new_password = ''.join(random.choices(string.ascii_letters + string.digits, k=10))
    user.set_password(new_password)
    user.save()
    
    messages.success(request, f"Le mot de passe de {user.username} a été réinitialisé. Nouveau mot de passe : {new_password}")
    return redirect(request.META.get('HTTP_REFERER', 'dashboard'))

@login_required
def admin_create_admin(request):
    if request.user.role != 'admin':
        return redirect('dashboard')
        
    if request.method == 'POST':
        username = request.POST.get('username')
        email = request.POST.get('email')
        first_name = request.POST.get('first_name')
        last_name = request.POST.get('last_name')
        
        password = ''.join(random.choices(string.ascii_letters + string.digits, k=12))
        
        try:
            CustomUser.objects.create_user(
                username=username,
                email=email,
                first_name=first_name,
                last_name=last_name,
                password=password,
                role='admin'
            )
            messages.success(request, f"Administrateur créé avec succès ! Identifiants : {username} / {password}")
            return redirect('admin_manage_users', role='admin')
        except Exception as e:
            messages.error(request, f"Erreur lors de la création : {e}")
            
    return render(request, 'dashboards/admin_create.html')

@login_required
def admin_diploma_detail(request, diploma_id):
    if request.user.role != 'admin':
        return redirect('dashboard')
        
    diploma = Diploma.objects.get(id=diploma_id)
    verifications = VerificationLog.objects.filter(diploma=diploma).order_by('-verified_at')
    
    return render(request, 'dashboards/admin_diploma_detail.html', {
        'diploma': diploma,
        'verifications': verifications
    })

@login_required
def emit_diploma(request):
    """View for institutions to issue a new diploma."""
    if request.user.role != 'institution':
        return redirect('dashboard')
    
    try:
        inst = Institution.objects.get(name=request.user.institution_name)
    except Institution.DoesNotExist:
        messages.error(request, "Votre institution n'est pas configurée.")
        return redirect('dashboard')

    if request.method == 'POST':
        # Manual form handling for simplicity
        try:
            diploma = Diploma.objects.create(
                student_first_name=request.POST.get('first_name'),
                student_last_name=request.POST.get('last_name'),
                student_email=request.POST.get('email'),
                student_id_number=request.POST.get('student_id'),
                degree_name=request.POST.get('degree'),
                major=request.POST.get('major', ''),
                graduation_date=request.POST.get('date'),
                institution=inst,
                issuer=request.user,
                pdf_file=request.FILES.get('pdf')
            )
            messages.success(request, f"Diplôme émis avec succès ! ID: {diploma.unique_identifier}")
            return redirect('dashboard_institution')
        except Exception as e:
            messages.error(request, f"Erreur lors de l'émission : {e}")

    return render(request, 'dashboards/emit.html')

@login_required
def diploma_pdf(request, diploma_id):
    """Serve a diploma PDF when available, otherwise show a friendly error."""
    if request.user.role != 'institution':
        return redirect('dashboard')

    try:
        inst = Institution.objects.get(name=request.user.institution_name)
    except Institution.DoesNotExist:
        messages.error(request, "Votre institution n'est pas configurée.")
        return redirect('dashboard')

    try:
        diploma = Diploma.objects.get(id=diploma_id, institution=inst)
    except Diploma.DoesNotExist:
        messages.error(request, "Ce diplôme est introuvable.")
        return redirect('dashboard_institution')

    if not diploma.pdf_file or not diploma.pdf_file.name:
        messages.error(request, "Le fichier PDF est indisponible pour ce diplôme.")
        return redirect(request.META.get('HTTP_REFERER', 'dashboard_institution'))

    if not default_storage.exists(diploma.pdf_file.name):
        messages.error(request, "Le fichier PDF est manquant sur le serveur.")
        return redirect(request.META.get('HTTP_REFERER', 'dashboard_institution'))

    return FileResponse(diploma.pdf_file.open('rb'), content_type='application/pdf')

from diplomas.blockchain_utils import get_algod_client, get_treasury_account

@login_required
def blockchain_status(request):
    """View for admin to check the status of the blockchain connection and treasury."""
    if request.user.role != 'admin':
        return redirect('dashboard')
        
    client = get_algod_client()
    status_data = {
        'connected': False,
        'last_round': 0,
        'treasury_address': None,
        'treasury_balance': 0,
        'error': None
    }
    
    try:
        status = client.status()
        status_data['connected'] = True
        status_data['last_round'] = status['last-round']
        
        _, addr, _ = get_treasury_account()
        if addr:
            status_data['treasury_address'] = addr
            account_info = client.account_info(addr)
            status_data['treasury_balance'] = account_info.get('amount', 0) / 1_000_000
    except Exception as e:
        status_data['error'] = str(e)
        
    return render(request, 'dashboards/blockchain_status.html', {'status': status_data})

@login_required
def institution_diploma_detail(request, diploma_id):
    if request.user.role != 'institution':
        return redirect('dashboard')
        
    try:
        inst = Institution.objects.get(name=request.user.institution_name)
        diploma = Diploma.objects.get(id=diploma_id, institution=inst)
    except (Institution.DoesNotExist, Diploma.DoesNotExist):
        messages.error(request, "Diplôme introuvable.")
        return redirect('institution_register')
        
    verifications = VerificationLog.objects.filter(diploma=diploma).order_by('-verified_at')
    
    return render(request, 'dashboards/institution_diploma_detail.html', {
        'diploma': diploma,
        'verifications': verifications
    })

from django.http import JsonResponse

@login_required
def get_student_info(request):
    """API endpoint for universities to fetch student info by INE."""
    if request.user.role != 'institution':
        return JsonResponse({'error': 'Unauthorized'}, status=403)
        
    ine = request.GET.get('ine', '').strip()
    try:
        student = CustomUser.objects.get(ine=ine, role='student')
        return JsonResponse({
            'success': True,
            'first_name': student.first_name,
            'last_name': student.last_name,
            'email': student.email,
            'student_id': student.ine
        })
    except CustomUser.DoesNotExist:
        return JsonResponse({'success': False, 'error': 'Étudiant non trouvé pour cet INE.'})

from accounts.models import TopUpRequest

@login_required
def request_algo_topup(request):
    """View for institutions to request ALGO top-up."""
    if request.user.role != 'institution':
        return redirect('dashboard')
    
    try:
        inst = Institution.objects.get(name=request.user.institution_name)
    except Institution.DoesNotExist:
        messages.error(request, "Institution non trouvée.")
        return redirect('dashboard_institution')
        
    if request.method == 'POST':
        # Check if already has a pending request
        if TopUpRequest.objects.filter(institution=inst, status='pending').exists():
            messages.warning(request, "Vous avez déjà une demande en attente.")
        else:
            TopUpRequest.objects.create(institution=inst, amount_requested=2)
            messages.success(request, "Demande de recharge de 2 ALGO envoyée à l'administrateur avec succès.")
            
    return redirect('dashboard_institution')

@login_required
def admin_topup_requests(request):
    if request.user.role != 'admin':
        return redirect('dashboard')
        
    requests = TopUpRequest.objects.all().order_by('-created_at')
    return render(request, 'dashboards/admin_topup_requests.html', {'requests': requests})

@login_required
def admin_approve_topup(request, req_id):
    if request.user.role != 'admin':
        return redirect('dashboard')
        
    try:
        topup = TopUpRequest.objects.get(id=req_id)
        if topup.status == 'pending':
            from diplomas.blockchain_utils import fund_account
            tx_id = fund_account(topup.institution.blockchain_address, topup.amount_requested)
            if tx_id:
                topup.status = 'approved'
                topup.save()
                messages.success(request, f"Recharge approuvée et effectuée. TxID: {tx_id}")
            else:
                messages.error(request, "Erreur lors de la transaction sur la blockchain. Vérifiez le solde de la trésorerie.")
        else:
            messages.warning(request, "Cette demande a déjà été traitée.")
    except TopUpRequest.DoesNotExist:
        messages.error(request, "Demande introuvable.")
        
    return redirect('admin_topup_requests')

