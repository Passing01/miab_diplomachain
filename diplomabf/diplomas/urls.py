from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DiplomaViewSet, InstitutionViewSet, VerifyDiplomaView, public_verify_view

router = DefaultRouter()
router.register(r'diplomas', DiplomaViewSet)
router.register(r'institutions', InstitutionViewSet)

urlpatterns = [
    path('verify-ui/', public_verify_view, name='diploma_verify_ui'),
    path('verify/', VerifyDiplomaView.as_view(), name='diploma_verify'),
    path('', include(router.urls)),
]
