from django.contrib import admin
from .models import Institution, Diploma

@admin.register(Institution)
class InstitutionAdmin(admin.ModelAdmin):
    list_display = ('name', 'acronym', 'is_active', 'created_at')
    search_fields = ('name', 'acronym')

@admin.register(Diploma)
class DiplomaAdmin(admin.ModelAdmin):
    list_display = ('degree_name', 'student_first_name', 'student_last_name', 'institution', 'unique_identifier', 'is_verified')
    list_filter = ('institution', 'is_verified', 'graduation_date')
    search_fields = ('student_first_name', 'student_last_name', 'unique_identifier', 'degree_name')
    readonly_fields = ('unique_identifier', 'created_at', 'updated_at')
    
    fieldsets = (
        ('Informations de Base', {
            'fields': ('degree_name', 'major', 'graduation_date', 'institution', 'issuer')
        }),
        ('Informations Étudiant', {
            'fields': ('student_first_name', 'student_last_name', 'student_id_number')
        }),
        ('Piliers de Certification', {
            'fields': ('unique_identifier', 'document_hash', 'blockchain_tx_id', 'is_verified')
        }),
        ('Métadonnées', {
            'fields': ('created_at', 'updated_at')
        }),
    )
