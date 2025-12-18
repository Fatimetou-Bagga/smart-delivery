from rest_framework import serializers
from .models import DeliveryRequest
from accounts.serializers import UserSerializer


class DeliveryRequestSerializer(serializers.ModelSerializer):

    client = UserSerializer(read_only=True)

    class Meta:
        model = DeliveryRequest
        fields = [
            'id',
            'client',
            'product_type',
            'description',
            'weight',
            'pickup_address',
            'delivery_address',
            'status',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'client',
            'status',
            'created_at',
            'updated_at',
        ]
