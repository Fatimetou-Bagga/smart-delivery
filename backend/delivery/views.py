from datetime import timezone
from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets, permissions

from delivery_requests.models import DeliveryRequest
from .models import Delivery
from .serializers import DeliverySerializer
from rest_framework.permissions import IsAuthenticated
from accounts.permissions import IsCourier
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework import status

class DeliveryViewSet(viewsets.ModelViewSet):

    serializer_class = DeliverySerializer
    
    def get_queryset(self):
        return Delivery.objects.filter(courier=self.request.user)
        
    @action(
        detail=False,
        methods=['post'],
        permission_classes=[permissions.IsAuthenticated, IsCourier]
    )
    def accept(self, request):
        """
        Le livreur accepte une demande de livraison
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

        # Créer la livraison
        delivery = Delivery.objects.create(
            delivery_request=delivery_request,
            courier=request.user,
            status='ASSIGNED'
        )

        # Mettre à jour la demande
        delivery_request.status = 'ACCEPTED'
        delivery_request.save()

        serializer = self.get_serializer(delivery)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    def perform_update(self, serializer):
        delivery = serializer.save()

        if delivery.status == 'DELIVERED' and delivery.delivered_at is None:
           delivery.delivered_at = timezone.now()
           delivery.save()
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve', 'update', 'partial_update']:
            permission_classes = [IsAuthenticated, IsCourier]

        elif self.action == 'accept':
            permission_classes = [IsAuthenticated, IsCourier]

        else:
            permission_classes = [IsAuthenticated]

        return [permission() for permission in permission_classes]
