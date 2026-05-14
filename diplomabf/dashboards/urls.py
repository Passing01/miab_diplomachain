from django.urls import path
from . import views

urlpatterns = [
    path('', views.dashboard_router, name='dashboard'),
    path('student/', views.student_dashboard, name='dashboard_student'),
    path('student/diplomas/', views.student_diplomas, name='student_diplomas'),
    path('student/verifications/', views.student_verifications, name='student_verifications'),
    path('student/diploma/<int:diploma_id>/download/', views.student_diploma_download, name='student_diploma_download'),
    
    path('institution/', views.institution_dashboard, name='dashboard_institution'),
    path('institution/emit/', views.emit_diploma, name='emit_diploma'),
    path('institution/diploma/<int:diploma_id>/pdf/', views.diploma_pdf, name='diploma_pdf'),
    path('institution/register/', views.institution_register, name='institution_register'),
    path('institution/search/', views.search_diplomas, name='search_diplomas'),
    
    path('recruiter/', views.recruiter_dashboard, name='dashboard_recruiter'),
    
    path('admin-panel/', views.admin_dashboard, name='dashboard_admin'),
    path('admin-panel/blockchain-status/', views.blockchain_status, name='blockchain_status'),
    # Admin Management
    path('admin/manage/<str:role>/', views.admin_manage_users, name='admin_manage_users'),
    path('admin/user/<int:user_id>/', views.admin_user_detail, name='admin_user_detail'),
    path('admin/user/<int:user_id>/toggle/', views.admin_toggle_user_status, name='admin_toggle_user_status'),
    path('admin/user/<int:user_id>/reset-password/', views.admin_reset_password, name='admin_reset_password'),
    path('admin/create/', views.admin_create_admin, name='admin_create_admin'),
    path('admin/diploma/<int:diploma_id>/', views.admin_diploma_detail, name='admin_diploma_detail'),
]
