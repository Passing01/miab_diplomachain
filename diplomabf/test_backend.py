import os
import django
import hashlib

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'diplomabf.settings')
django.setup()

from diplomas.models import Diploma, Institution
from accounts.models import CustomUser
from django.core.files.base import ContentFile

def test_hashing():
    # Create an institution
    inst, _ = Institution.objects.get_or_create(name="Université de Ouagadougou", acronym="UO")
    
    # Create a user (issuer)
    user, _ = CustomUser.objects.get_or_create(username="admin_uo", role="institution")
    user.set_password("password123")
    user.save()

    # Create a dummy PDF content
    pdf_content = b"This is a fake diploma PDF content for hashing test."
    pdf_file = ContentFile(pdf_content, name="test_diploma.pdf")

    # Create diploma
    diploma = Diploma.objects.create(
        student_first_name="Jean",
        student_last_name="Dupont",
        student_id_number="12345",
        degree_name="Master en Informatique",
        graduation_date="2024-05-01",
        institution=inst,
        issuer=user,
        pdf_file=pdf_file
    )

    print(f"Diploma Created: {diploma.unique_identifier}")
    print(f"Computed Hash: {diploma.document_hash}")
    
    # Manual hash calculation to verify
    expected_hash = hashlib.sha256(pdf_content).hexdigest()
    print(f"Expected Hash: {expected_hash}")

    if diploma.document_hash == expected_hash:
        print("✅ SUCCESS: Hashing logic works!")
    else:
        print("❌ FAILURE: Hashing logic mismatch.")

if __name__ == "__main__":
    test_hashing()
