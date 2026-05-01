from pypdf import PdfReader, PdfWriter
import io
from django.core.files.base import ContentFile

def watermark_pdf(pdf_file, unique_id):
    """
    Injects a unique identifier into the PDF metadata.
    This serves as a basic version of Pilier 01.
    """
    try:
        reader = PdfReader(pdf_file)
        writer = PdfWriter()

        for page in reader.pages:
            writer.add_page(page)

        # Add metadata
        metadata = reader.metadata
        new_metadata = {k: v for k, v in metadata.items()} if metadata else {}
        new_metadata["/MIAB_ID"] = unique_id
        
        writer.add_metadata(new_metadata)

        # Save to memory
        output_stream = io.BytesIO()
        writer.write(output_stream)
        output_stream.seek(0)
        
        return ContentFile(output_stream.read(), name=pdf_file.name)
    except Exception as e:
        print(f"Watermarking error: {e}")
        return pdf_file
