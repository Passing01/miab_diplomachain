from django.urls import path
from . import views

urlpatterns = [
    path('', views.dashboard_router, name='dashboard'),
    path('student/', views.student_dashboard, name='dashboard_student'),
    path('institution/', views.institution_dashboard, name='dashboard_institution'),
    path('institution/emit/', views.emit_diploma, name='emit_diploma'),
    path('institution/register/', views.institution_register, name='institution_register'),
    path('institution/search/', views.search_diplomas, name='search_diplomas'),
    path('recruiter/', views.recruiter_dashboard, name='dashboard_recruiter'),
    path('admin-panel/', views.admin_dashboard, name='dashboard_admin'),
]
