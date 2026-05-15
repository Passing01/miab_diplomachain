from django.contrib.auth.models import AbstractUser
from django.db import models

class CustomUser(AbstractUser):
    ROLE_CHOICES = (
        ('student', 'Étudiant'),
        ('institution', 'Institution/Université'),
        ('recruiter', 'Recruteur/Employeur'),
        ('admin', 'Administrateur'),
    )
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='student')
    institution_name = models.CharField(max_length=255, blank=True, null=True)
    company_name = models.CharField(max_length=255, blank=True, null=True)
    job_title = models.CharField(max_length=255, blank=True, null=True)
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    ine = models.CharField(max_length=50, blank=True, null=True, unique=True, verbose_name="INE / ID National")

    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"

class TopUpRequest(models.Model):
    institution = models.ForeignKey('diplomas.Institution', on_delete=models.CASCADE, related_name='topup_requests')
    amount_requested = models.PositiveIntegerField(default=2, verbose_name="Nombre d'ALGO demandés")
    status = models.CharField(
        max_length=20, 
        choices=[('pending', 'En attente'), ('approved', 'Approuvé'), ('rejected', 'Rejeté')],
        default='pending'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Demande {self.amount_requested} ALGO - {self.institution.name} ({self.get_status_display()})"
