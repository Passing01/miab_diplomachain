from rest_framework import serializers
from .models import Diploma, Institution

class InstitutionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Institution
        fields = '__all__'

class DiplomaSerializer(serializers.ModelSerializer):
    institution_name = serializers.ReadOnlyField(source='institution.name')
    
    class Meta:
        model = Diploma
        fields = (
            'id', 'student_first_name', 'student_last_name', 'student_id_number',
            'degree_name', 'major', 'graduation_date', 'institution', 'institution_name',
            'pdf_file', 'unique_identifier', 'document_hash', 'blockchain_tx_id',
            'is_verified', 'created_at'
        )
        read_only_fields = ('unique_identifier', 'document_hash', 'blockchain_tx_id', 'is_verified', 'created_at')

from .models import VerificationLog

class VerificationLogSerializer(serializers.ModelSerializer):
    student_name = serializers.ReadOnlyField(source='diploma.student_first_name')
    student_last_name = serializers.ReadOnlyField(source='diploma.student_last_name')
    degree_name = serializers.ReadOnlyField(source='diploma.degree_name')
    student_id = serializers.ReadOnlyField(source='diploma.student_id_number')
    
    class Meta:
        model = VerificationLog
        fields = ('id', 'student_name', 'student_last_name', 'degree_name', 'student_id', 'verified_at')
