from django.db import models

# Create your models here.
from django.db import models
from django.conf import settings
from delivery_requests.models import DeliveryRequest
from django.conf import settings
from django.db import models

class TrackingPoint(models.Model):
    delivery = models.ForeignKey(
        "delivery.Delivery",
        on_delete=models.CASCADE,
        related_name="tracking_points",
    )
    courier = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="tracking_points",
    )
    lat = models.FloatField()
    lng = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [
            models.Index(fields=["delivery", "-created_at"]),
        ]
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.delivery_id} @ ({self.lat},{self.lng})"


class Delivery(models.Model):

    STATUS_CHOICES = [
        ('ASSIGNED', 'Assignée'),
        ('IN_PROGRESS', 'En cours'),
        ('DELIVERED', 'Livrée'),
        ('CANCELLED', 'Annulée'),
    ]

    # Lien 1–1 avec la demande
    delivery_request = models.OneToOneField(
        DeliveryRequest,
        on_delete=models.CASCADE,
        related_name='delivery'
    )

    # Livreur
    courier = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='deliveries'
    )

    # Statut de la livraison
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='ASSIGNED'
    )

    # Dates importantes
    assigned_at = models.DateTimeField(auto_now_add=True)
    delivered_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"Delivery #{self.id} - {self.status}"
