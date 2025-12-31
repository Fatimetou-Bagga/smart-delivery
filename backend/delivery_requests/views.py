from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets, permissions
from .models import DeliveryRequest
from .serializers import DeliveryRequestSerializer
from rest_framework.permissions import IsAuthenticated
from accounts.permissions import IsClient, IsCourier
from rest_framework.decorators import action
from rest_framework.response import Response


class DeliveryRequestViewSet(viewsets.ModelViewSet):

    serializer_class = DeliveryRequestSerializer
    permission_classes = [IsAuthenticated,IsClient]
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


