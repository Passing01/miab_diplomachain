from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from diplomas.models import Diploma, Institution, VerificationLog
from accounts.models import CustomUser
from django.db.models import Count
from diplomas.blockchain_utils import get_algod_client

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
    diplomas = Diploma.objects.filter(student_email=request.user.email)
    verifications = VerificationLog.objects.filter(diploma__student_email=request.user.email).order_by('-verified_at')
    return render(request, 'dashboards/student.html', {
        'diplomas': diplomas,
        'verifications': verifications
    })

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
        except Institution.DoesNotExist:
            pass

    return render(request, 'dashboards/search_diplomas.html', {
        'query': query,
        'results': results
    })

@login_required
def admin_dashboard(request):
    if request.user.role != 'admin':
        return dashboard_router(request)
        
    stats = {
        'total_users': CustomUser.objects.count(),
        'total_institutions': Institution.objects.count(),
        'total_diplomas': Diploma.objects.count(),
        'verified_diplomas': Diploma.objects.filter(is_verified=True).count(),
    }
    return render(request, 'dashboards/admin.html', {'stats': stats})

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

    return render(request, 'dashboards/emit.html', {'institution': inst})
