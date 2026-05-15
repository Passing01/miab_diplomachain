from django.urls import path
from .views import login_view, register_view, logout_view, profile_view, change_password

urlpatterns = [
    # Template Views
    path('login/', login_view, name='login'),
    path('register/', register_view, name='register'),
    path('logout/', logout_view, name='logout'),
    path('profile/', profile_view, name='profile'),
    path('change-password/', change_password, name='change_password'),
]
