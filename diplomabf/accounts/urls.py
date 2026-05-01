from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import RegisterView, UserDetailView, login_view, register_view, logout_view

urlpatterns = [
    # Template Views
    path('login/', login_view, name='login'),
    path('register/', register_view, name='register'),
    path('logout/', logout_view, name='logout'),
    
    # API Routes
    path('api/register/', RegisterView.as_view(), name='api_auth_register'),
    path('api/login/', TokenObtainPairView.as_view(), name='api_token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('profile/', UserDetailView.as_view(), name='user_profile'),
]
