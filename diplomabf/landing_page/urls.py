from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='home'),
    path('probleme/', views.probleme, name='probleme'),
    path('solution/', views.solution, name='solution'),
    path('fonctionnement/', views.comment, name='comment'),
    path('technologie/', views.technologie, name='technologie'),
]
