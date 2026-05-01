from django.db import models
from django.conf import settings
import uuid
import hashlib
from .utils import watermark_pdf

class Institution(models.Model):
    name = models.CharField(max_length=255)
    acronym = models.CharField(max_length=20, blank=True)
    website = models.URLField(blank=True)
    blockchain_address = models.CharField(max_length=58, blank=True, null=True)
    blockchain_private_key = models.CharField(max_length=128, blank=True, null=True)
    blockchain_mnemonic = models.TextField(blank=True, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class Diploma(models.Model):
    # Base Info
    student_first_name = models.CharField(max_length=100)
    student_last_name = models.CharField(max_length=100)
    student_email = models.EmailField(blank=True, null=True)
    student_id_number = models.CharField(max_length=50, verbose_name="Numéro d'étudiant")
    
    degree_name = models.CharField(max_length=255, verbose_name="Intitulé du diplôme")
    major = models.CharField(max_length=255, blank=True)
    graduation_date = models.DateField()
    
    institution = models.ForeignKey(Institution, on_delete=models.CASCADE, related_name='diplomas')
    issuer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, related_name='issued_diplomas')

    # Document File
    pdf_file = models.FileField(upload_to='diplomas/pdfs/', blank=True, null=True)

    # Pilier 01: Tatouage Numérique Invisible (12 chars identifier)
    unique_identifier = models.CharField(max_length=12, unique=True, editable=False)
    
    # Pilier 02: Hash Cryptographique SHA-256
    document_hash = models.CharField(max_length=64, unique=True, blank=True, null=True, editable=False)
    
    # Pilier 03: Ancrage Blockchain Algorand
    blockchain_tx_id = models.CharField(max_length=100, blank=True, null=True, verbose_name="ID Transaction Algorand")
    
    # Status
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def generate_hash(self):
        """Generates SHA-256 hash of the uploaded PDF file."""
        if self.pdf_file:
            hasher = hashlib.sha256()
            for chunk in self.pdf_file.chunks():
                hasher.update(chunk)
            return hasher.hexdigest()
        return None

    def save(self, *args, **kwargs):
        # 1. Pilier 01: Identifier generation
        if not self.unique_identifier:
            self.unique_identifier = uuid.uuid4().hex[:12].upper()
        
        # 2. Watermarking (only on first save or new file)
        # To avoid infinite recursion, we check a flag or if hash is missing
        is_new_file = self.pdf_file and not self.document_hash
        
        if is_new_file:
            # Watermark the PDF with the MIAB_ID
            watermarked_file = watermark_pdf(self.pdf_file, self.unique_identifier)
            self.pdf_file.save(self.pdf_file.name, watermarked_file, save=False)
            
            # 3. Pilier 02: Auto-hashing of the watermarked PDF
            self.document_hash = self.generate_hash()
            
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.degree_name} - {self.student_first_name} {self.student_last_name}"

class VerificationLog(models.Model):
    diploma = models.ForeignKey(Diploma, on_delete=models.CASCADE, related_name='verification_logs')
    recruiter = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    verified_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.recruiter.username} verified {self.diploma.unique_identifier}"
