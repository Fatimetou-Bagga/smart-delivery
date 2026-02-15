# delivery/views.py

from django.utils import timezone

from rest_framework import viewsets, permissions, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action
from rest_framework.response import Response

from delivery_requests.models import DeliveryRequest
from accounts.permissions import IsCourier

from .models import Delivery, TrackingPoint
from .serializers import DeliverySerializer, TrackingPointCreateSerializer, TrackingPointSerializer


class DeliveryViewSet(viewsets.ModelViewSet):
    serializer_class = DeliverySerializer

    def get_queryset(self):
        return Delivery.objects.filter(courier=self.request.user)

    def get_permissions(self):
        # Courier-only for all delivery operations
        if self.action in ['list', 'retrieve', 'update', 'partial_update', 'accept', 'push_location']:
            permission_classes = [IsAuthenticated, IsCourier]
        else:
            permission_classes = [IsAuthenticated]
        return [p() for p in permission_classes]

    @action(
        detail=False,
        methods=['post'],
        permission_classes=[IsAuthenticated, IsCourier],
        url_path='accept'
    )
    def accept(self, request):
        """
        Courier accepts a pending delivery request.
        POST /api/deliveries/accept/
        body: { "delivery_request_id": <id> }
        """
        request_id = request.data.get('delivery_request_id')

        try:
            delivery_request = DeliveryRequest.objects.get(
                id=request_id,
                status='PENDING'
            )
        except DeliveryRequest.DoesNotExist:
            return Response(
                {"error": "Demande non disponible"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Create delivery
        delivery = Delivery.objects.create(
            delivery_request=delivery_request,
            courier=request.user,
            status='ASSIGNED'
        )

        # Update request status
        delivery_request.status = 'ACCEPTED'
        delivery_request.save(update_fields=['status'])

        serializer = self.get_serializer(delivery)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def perform_update(self, serializer):
        """
        Keep DeliveryRequest status in sync with Delivery status.
        """
        delivery = serializer.save()
        dr = delivery.delivery_request

        # If courier starts the delivery
        if delivery.status == 'IN_PROGRESS' and dr.status != 'IN_PROGRESS':
            dr.status = 'IN_PROGRESS'
            dr.save(update_fields=['status'])

        # If courier finishes the delivery
        if delivery.status == 'DELIVERED':
            if delivery.delivered_at is None:
                delivery.delivered_at = timezone.now()
                delivery.save(update_fields=['delivered_at'])

            if dr.status != 'DELIVERED':
                dr.status = 'DELIVERED'
                dr.save(update_fields=['status'])

    @action(
        detail=False,
        methods=["post"],
        url_path="location",
        permission_classes=[IsAuthenticated, IsCourier]
    )
    def push_location(self, request):
        """
        Courier sends location updates every 3-5 seconds.
        POST /api/deliveries/location/
        body: { "lat": ..., "lng": ... }
        """
        serializer = TrackingPointCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        active_delivery = Delivery.objects.filter(
            courier=request.user,
            status__in=["ASSIGNED", "IN_PROGRESS"]
        ).order_by("-assigned_at").first()

        if not active_delivery:
            return Response(
                {"detail": "No active delivery to track"},
                status=status.HTTP_400_BAD_REQUEST
            )

        point = TrackingPoint.objects.create(
            delivery=active_delivery,
            courier=request.user,
            lat=serializer.validated_data["lat"],
            lng=serializer.validated_data["lng"],
        )

        return Response(TrackingPointSerializer(point).data, status=status.HTTP_201_CREATED)
