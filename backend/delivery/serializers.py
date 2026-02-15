from django.utils import timezone
from rest_framework import serializers
from .models import Delivery
from delivery_requests.serializers import DeliveryRequestSerializer
from accounts.serializers import UserSerializer
from rest_framework import serializers
from .models import TrackingPoint

class TrackingPointCreateSerializer(serializers.Serializer):
    lat = serializers.FloatField()
    lng = serializers.FloatField()

    def validate_lat(self, v):
        if v < -90 or v > 90:
            raise serializers.ValidationError("Invalid latitude")
        return v

    def validate_lng(self, v):
        if v < -180 or v > 180:
            raise serializers.ValidationError("Invalid longitude")
        return v


class TrackingPointSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrackingPoint
        fields = ["id", "lat", "lng", "created_at"]


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
        new_status = validated_data.get('status', instance.status)
        current_status = instance.status

        # Règles de transition autorisées
        allowed_transitions = {
            'ASSIGNED': ['IN_PROGRESS'],
            'IN_PROGRESS': ['DELIVERED'],
        }

        # Livraison déjà terminée → bloquée
        if current_status == 'DELIVERED':
            raise serializers.ValidationError(
                "Une livraison terminée ne peut plus être modifiée."
            )

        # Vérification des transitions
        if new_status != current_status:
            if new_status not in allowed_transitions.get(current_status, []):
                raise serializers.ValidationError(
                    f"Transition interdite : {current_status} → {new_status}"
                )

        # Si livrée, on enregistre la date
        if new_status == 'DELIVERED':
            instance.delivered_at = timezone.now()

        return super().update(instance, validated_data)