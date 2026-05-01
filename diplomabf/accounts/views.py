from rest_framework import generics, permissions
from django.shortcuts import render, redirect
from django.contrib.auth import login, authenticate, logout
from django.contrib import messages
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
        
        # 1. Try traditional username authentication
        user = authenticate(username=u, password=p)
        
        # 2. If it fails, try email authentication
        if not user:
            try:
                # Find the username associated with this email
                user_obj = CustomUser.objects.get(email=u)
                user = authenticate(username=user_obj.username, password=p)
            except CustomUser.DoesNotExist:
                user = None

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
        if data.get('password') != data.get('confirm_password'):
            messages.error(request, "Les mots de passe ne correspondent pas")
        else:
            try:
                user = CustomUser.objects.create_user(
                    username=data.get('username'),
                    email=data.get('email'),
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
                
                login(request, user)
                return redirect('dashboard')
            except Exception as e:
                messages.error(request, f"Erreur: {e}")
    return render(request, 'accounts/register.html')

def logout_view(request):
    logout(request)
    return redirect('home')
