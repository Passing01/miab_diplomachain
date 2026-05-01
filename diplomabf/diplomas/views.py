from django.shortcuts import render
from rest_framework import viewsets, permissions, status, views
from rest_framework.response import Response
from rest_framework.decorators import action
from drf_spectacular.utils import extend_schema, OpenApiParameter
from .models import Diploma, Institution, VerificationLog
from .serializers import DiplomaSerializer, InstitutionSerializer
from .blockchain_utils import anchor_hash_on_algorand
import hashlib

class IsInstitution(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'institution'

class InstitutionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Institution.objects.all()
    serializer_class = InstitutionSerializer
    permission_classes = [permissions.IsAuthenticated]

class DiplomaViewSet(viewsets.ModelViewSet):
    queryset = Diploma.objects.all()
    serializer_class = DiplomaSerializer

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsInstitution()]
        return [permissions.IsAuthenticated()]

    def perform_create(self, serializer):
        # Automatically set the issuer as the current user
        serializer.save(issuer=self.request.user)
        
    def get_queryset(self):
        user = self.request.user
        if user.role == 'institution':
            # Institutions see diplomas they issued or for their institution
            return Diploma.objects.filter(institution__name=user.institution_name)
        elif user.role == 'student':
            # Students see diplomas matching their email
            return Diploma.objects.filter(student_email=user.email)
        return Diploma.objects.all()

    @action(detail=True, methods=['post'], permission_classes=[IsInstitution])
    def anchor(self, request, pk=None):
        """Anchors the diploma hash to Algorand."""
        diploma = self.get_object()
        if not diploma.document_hash:
            return Response({"error": "No document hash found. Please upload a PDF first."}, status=status.HTTP_400_BAD_REQUEST)
        
        if diploma.blockchain_tx_id:
            return Response({"message": "Already anchored", "tx_id": diploma.blockchain_tx_id}, status=status.HTTP_200_OK)
        
        # Get the institution's private key
        try:
            institution = diploma.institution
            if not institution.blockchain_private_key:
                return Response({"error": "Institution has no blockchain identity. Please contact support."}, status=status.HTTP_400_BAD_REQUEST)
            
            # Call the blockchain utility with real key
            tx_id = anchor_hash_on_algorand(diploma.document_hash, institution.blockchain_private_key)
            
            if tx_id:
                diploma.blockchain_tx_id = tx_id
                diploma.is_verified = True
                diploma.save()
                return Response({"message": "Successfully anchored to Algorand", "tx_id": tx_id}, status=status.HTTP_200_OK)
            else:
                return Response({"error": "Blockchain anchoring failed"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        except Exception as e:
            return Response({"error": f"Error: {e}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

def public_verify_view(request):
    """View to render the public verification UI."""
    return render(request, 'diplomas/verify.html')

class VerifyDiplomaView(views.APIView):
    """Public endpoint to verify a diploma."""
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        parameters=[
            OpenApiParameter(name='id', description='Unique identifier (12 chars)', required=False, type=str),
            OpenApiParameter(name='hash', description='SHA-256 hash', required=False, type=str),
        ],
        responses={200: DiplomaSerializer}
    )
    def post(self, request):
        """Verify a diploma by uploading the PDF file."""
        # Standardize: accept 'pdf' (web) or 'file' (mobile)
        pdf_file = request.FILES.get('pdf') or request.FILES.get('file')
        
        if not pdf_file:
            return Response({"error": "No file uploaded"}, status=status.HTTP_400_BAD_REQUEST)
        
        # Calculate SHA-256 of the uploaded file
        sha256_hash = hashlib.sha256()
        for chunk in pdf_file.chunks():
            sha256_hash.update(chunk)
        doc_hash = sha256_hash.hexdigest()
        
        try:
            diploma = Diploma.objects.get(document_hash=doc_hash)
            
            # Log verification if recruiter
            if request.user.is_authenticated and request.user.role == 'recruiter':
                VerificationLog.objects.create(diploma=diploma, recruiter=request.user)

            serializer = DiplomaSerializer(diploma)
            return Response({
                "status": "Authentic",
                "is_blockchain_verified": bool(diploma.blockchain_tx_id),
                "institution_name": diploma.institution.name,
                "student_first_name": diploma.student_first_name,
                "student_last_name": diploma.student_last_name,
                "degree_name": diploma.degree_name,
                "document_hash": diploma.document_hash,
                "blockchain_tx_id": diploma.blockchain_tx_id,
                "data": serializer.data
            }, status=status.HTTP_200_OK)
        except Diploma.DoesNotExist:
            return Response({"status": "Invalid", "message": "Ce document est inconnu ou a été modifié (Échec de l'empreinte numérique)."}, status=status.HTTP_404_NOT_FOUND)

    def get(self, request):
        identifier = request.query_params.get('id', '').strip()
        doc_hash = request.query_params.get('hash', '').strip()

        if not identifier and not doc_hash:
            return Response({"error": "Veuillez fournir un identifiant ou un fichier."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            if identifier:
                # Robust matching: strip prefix 'MIAB-', remove dashes, uppercase
                clean_id = identifier.upper()
                if clean_id.startswith('MIAB-'):
                    clean_id = clean_id[5:]
                clean_id = clean_id.replace('-', '')
                
                # Search by unique_identifier OR student_id_number (matricule)
                from django.db.models import Q
                diplomas = Diploma.objects.filter(
                    Q(unique_identifier=clean_id) | Q(student_id_number=identifier) | Q(student_id_number=clean_id)
                )
                
                if not diplomas.exists():
                    raise Diploma.DoesNotExist()
                
                # If multiple found (e.g. same student has multiple diplomas), pick the latest one
                diploma = diplomas.order_by('-created_at').first()
            else:
                diploma = Diploma.objects.get(document_hash=doc_hash)
            
            # Log verification if recruiter
            if request.user.is_authenticated and request.user.role == 'recruiter':
                VerificationLog.objects.create(diploma=diploma, recruiter=request.user)

            serializer = DiplomaSerializer(diploma)
            return Response({
                "status": "Authentic",
                "is_blockchain_verified": bool(diploma.blockchain_tx_id),
                "institution_name": diploma.institution.name,
                "student_first_name": diploma.student_first_name,
                "student_last_name": diploma.student_last_name,
                "degree_name": diploma.degree_name,
                "document_hash": diploma.document_hash,
                "blockchain_tx_id": diploma.blockchain_tx_id,
                "data": serializer.data
            }, status=status.HTTP_200_OK)
        except Diploma.DoesNotExist:
            return Response({"status": "Invalid", "message": "Aucun diplôme trouvé avec ces informations dans notre registre."}, status=status.HTTP_404_NOT_FOUND)

from .serializers import VerificationLogSerializer

class VerificationLogViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = VerificationLogSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        # Recruiters see their own logs
        if self.request.user.role == 'recruiter':
            return VerificationLog.objects.filter(recruiter=self.request.user).order_by('-verified_at')
        return VerificationLog.objects.none()
