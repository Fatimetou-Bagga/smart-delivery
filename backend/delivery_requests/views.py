from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets, permissions
from .models import DeliveryRequest
from .serializers import DeliveryRequestSerializer
from rest_framework.permissions import IsAuthenticated
from accounts.permissions import IsClient

class DeliveryRequestViewSet(viewsets.ModelViewSet):

    serializer_class = DeliveryRequestSerializer
    permission_classes = [IsAuthenticated,IsClient]

    def get_queryset(self):
        user = self.request.user
        return DeliveryRequest.objects.filter(client=self.request.user)

    def perform_create(self, serializer):
        serializer.save(client=self.request.user)
