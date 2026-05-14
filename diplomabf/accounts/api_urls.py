from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import RegisterView, api_profile_view

urlpatterns = [
    path('register/', RegisterView.as_view(), name='api_auth_register'),
    path('login/', TokenObtainPairView.as_view(), name='api_token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('profile/', api_profile_view, name='api_profile'),
]
