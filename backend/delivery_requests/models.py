from django.db import models

# Create your models here.
from django.db import models
from django.conf import settings


class DeliveryRequest(models.Model):

    PRODUCT_TYPES = [
        ('DOC', 'Documents'),
        ('FOOD', 'Nourriture'),
        ('ELEC', 'Électronique'),
        ('CLOT', 'Vêtements'),
        ('OTHER', 'Autre'),
    ]

    STATUS_CHOICES = [
        ('PENDING', 'En attente'),
        ('ACCEPTED', 'Acceptée'),
        ('IN_PROGRESS', 'En cours'),
        ('DELIVERED', 'Livrée'),
        ('CANCELLED', 'Annulée'),
    ]

    # Utilisateur qui fait la demande
    client = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='delivery_requests'
    )

    # Informations sur le colis
    product_type = models.CharField(
        max_length=20,
        choices=PRODUCT_TYPES
    )
    description = models.TextField()
    weight = models.FloatField(help_text="Poids en kg")

    # Adresses
    pickup_address = models.CharField(max_length=255)
    delivery_address = models.CharField(max_length=255)

    # Statut de la demande
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='PENDING'
    )

    # Dates
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"DeliveryRequest #{self.id} - {self.product_type}"
