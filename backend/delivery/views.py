from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets, permissions
from .models import Delivery
from .serializers import DeliverySerializer
from rest_framework.permissions import IsAuthenticated
from accounts.permissions import IsCourier

class DeliveryViewSet(viewsets.ModelViewSet):

    serializer_class = DeliverySerializer
    permission_classes = [IsAuthenticated,IsCourier]

    def get_queryset(self):
        return Delivery.objects.filter(courier=self.request.user)
        
