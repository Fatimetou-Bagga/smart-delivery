# config/api_urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter

from delivery_requests.views import DeliveryRequestViewSet
from delivery.views import DeliveryViewSet

router = DefaultRouter()
router.register(r"delivery-requests", DeliveryRequestViewSet, basename="delivery-request")
router.register(r"deliveries", DeliveryViewSet, basename="delivery")

urlpatterns = [
    # API routers
    path("", include(router.urls)),

    # Accounts/auth endpoints
    path("", include("accounts.urls")),
]
