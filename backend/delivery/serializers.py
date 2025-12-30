from django.utils import timezone
from rest_framework import serializers
from .models import Delivery
from delivery_requests.serializers import DeliveryRequestSerializer
from accounts.serializers import UserSerializer


class DeliverySerializer(serializers.ModelSerializer):

    delivery_request = DeliveryRequestSerializer(read_only=True)
    courier = UserSerializer(read_only=True)

    class Meta:
        model = Delivery
        fields = [
            'id',
            'delivery_request',
            'courier',
            'status',
            'assigned_at',
            'delivered_at',
        ]
        read_only_fields = [
            'id',
            'delivery_request',
            'courier',
            'assigned_at',
            'delivered_at',
        ]
    def update(self, instance, validated_data):
        if validated_data.get('status') == 'DELIVERED':
           instance.delivered_at = timezone.now()
           return super().update(instance, validated_data)