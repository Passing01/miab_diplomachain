from rest_framework import generics, permissions, status
from rest_framework.response import Response
from django.shortcuts import render, redirect
from django.contrib.auth import login, authenticate, logout
from django.contrib import messages
from django.db import IntegrityError
from .serializers import UserSerializer
from .models import CustomUser
from diplomas.models import Institution
from diplomas.blockchain_utils import onboard_university

class RegisterView(generics.CreateAPIView):
    queryset = CustomUser.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = UserSerializer

class UserDetailView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    def get_object(self):
        return self.request.user

# Template-based views
def login_view(request):
    if request.method == 'POST':
        u = request.POST.get('username')
        p = request.POST.get('password')
        
        # The custom backend handles both username and email automatically
        user = authenticate(request, username=u, password=p)
        
        if user:
            login(request, user)
            return redirect('dashboard')
        else:
            messages.error(request, "Identifiants invalides (Vérifiez votre nom d'utilisateur ou email)")
    return render(request, 'accounts/login.html')

def register_view(request):
    if request.method == 'POST':
        # Simple registration logic
        data = request.POST
        username = (data.get('username') or '').strip()
        email = (data.get('email') or '').strip()

        if data.get('password') != data.get('confirm_password'):
            messages.error(request, "Les mots de passe ne correspondent pas")
        elif CustomUser.objects.filter(username=username).exists():
            messages.error(request, "Ce nom d'utilisateur est déjà utilisé")
        elif email and CustomUser.objects.filter(email=email).exists():
            messages.error(request, "Cet email est déjà utilisé")
        else:
            try:
                user = CustomUser.objects.create_user(
                    username=username,
                    email=email,
                    password=data.get('password'),
                    first_name=data.get('first_name'),
                    last_name=data.get('last_name'),
                    role=data.get('role'),
                    institution_name=data.get('institution_name', ''),
                    company_name=data.get('company_name', ''),
                    job_title=data.get('job_title', '')
                )
                
                # If role is institution, create Institution object and onboard
                if user.role == 'institution':
                    inst = Institution.objects.create(name=user.institution_name)
                    # Blockchain Onboarding
                    address, private_key, mnemonic_phrase = onboard_university(inst.name)
                    inst.blockchain_address = address
                    inst.blockchain_private_key = private_key
                    inst.blockchain_mnemonic = mnemonic_phrase
                    inst.save()
                
                # Specify backend to avoid 'multiple authentication backends' error
                login(request, user, backend='accounts.backends.EmailOrUsernameModelBackend')
                return redirect('dashboard')
            except IntegrityError:
                messages.error(request, "Utilisateur déjà existant. Choisissez un autre identifiant.")
            except Exception as e:
                messages.error(request, f"Erreur: {e}")
    return render(request, 'accounts/register.html')

def logout_view(request):
    logout(request)
    return redirect('home')

from django.contrib.auth.decorators import login_required
@login_required
def profile_view(request):
    """View to display user profile information."""
    return render(request, 'accounts/profile.html')

from django.contrib.auth import update_session_auth_hash
from django.contrib.auth.forms import PasswordChangeForm

@login_required
def change_password(request):
    """View to allow users to change their password."""
    if request.method == 'POST':
        form = PasswordChangeForm(request.user, request.POST)
        if form.is_valid():
            user = form.save()
            update_session_auth_hash(request, user)  # Important to keep the user logged in
            messages.success(request, 'Votre mot de passe a été mis à jour avec succès !')
            return redirect('profile')
        else:
            messages.error(request, 'Veuillez corriger les erreurs ci-dessous.')
    else:
        form = PasswordChangeForm(request.user)
    return render(request, 'accounts/change_password.html', {'form': form})

from django.http import JsonResponse
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def api_profile_view(request):
    return Response({
        'id': request.user.id,
        'username': request.user.username,
        'email': request.user.email,
        'first_name': request.user.first_name,
        'last_name': request.user.last_name,
        'role': request.user.role,
        'company_name': request.user.company_name,
        'job_title': request.user.job_title,
        'institution_name': request.user.institution_name,
    })
