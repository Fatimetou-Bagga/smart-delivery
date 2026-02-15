from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets, permissions
from .models import DeliveryRequest
from .serializers import DeliveryRequestSerializer
from rest_framework.permissions import IsAuthenticated
from accounts.permissions import IsClient, IsCourier
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework import status

from delivery.models import Delivery, TrackingPoint
from delivery.serializers import TrackingPointSerializer
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone


class DeliveryRequestViewSet(viewsets.ModelViewSet):

    serializer_class = DeliveryRequestSerializer
    
    @action(
        detail=False,
        methods=['get'],
        permission_classes=[permissions.IsAuthenticated, IsCourier]
    )
    def available(self, request):
        """
        Liste des demandes disponibles pour les livreurs
        """
        requests = DeliveryRequest.objects.filter(status='PENDING')
        serializer = self.get_serializer(requests, many=True)
        return Response(serializer.data)
    
    def get_queryset(self):
        user = self.request.user
        return DeliveryRequest.objects.filter(client=self.request.user)

    def perform_create(self, serializer):
        serializer.save(client=self.request.user)

    @action(
        detail=True,
        methods=["post"],
        url_path="confirm-received",
        permission_classes=[permissions.IsAuthenticated, IsClient],
    )
    def confirm_received(self, request, pk=None):
        """
        Client confirms delivery.
        POST /api/delivery-requests/{id}/confirm-received/

        This will set:
          - DeliveryRequest.status = DELIVERED
          - Delivery.status = DELIVERED (if delivery exists)
          - Delivery.delivered_at = now (if not set)
        """
        dr = self.get_object()

        # Must have an assigned delivery
        try:
            delivery = dr.delivery
        except Exception:
            return Response(
                {"detail": "No delivery assigned yet"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Update both sides
        dr.status = "DELIVERED"
        dr.save(update_fields=["status", "updated_at"])

        delivery.status = "DELIVERED"
        if delivery.delivered_at is None:
            delivery.delivered_at = timezone.now()
        delivery.save(update_fields=["status", "delivered_at"])

        return Response({"success": True, "delivery_request_id": dr.id, "status": dr.status})

    @action(detail=True, methods=["get"], url_path="tracking/latest", permission_classes=[IsAuthenticated])
    def tracking_latest(self, request, pk=None):
        """
        Client polls every ~2 seconds.
        GET /api/delivery-requests/{id}/tracking/latest/
        """
        dr = self.get_object()  # respects your queryset filtering (client owns it)

        # delivery exists?
        try:
            delivery = dr.delivery
        except Exception:
            return Response({"detail": "No delivery assigned yet"}, status=status.HTTP_404_NOT_FOUND)

        point = delivery.tracking_points.order_by("-created_at").first()
        if not point:
            return Response({"detail": "No tracking data yet"}, status=status.HTTP_404_NOT_FOUND)

        return Response({
            "delivery_id": delivery.id,
            "delivery_status": delivery.status,
            "lat": point.lat,
            "lng": point.lng,
            "updated_at": point.created_at,
        })

