from django.db import models

# Create your models here.
from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    role = models.CharField(max_length=20)
    is_available = models.BooleanField(default=False)
    ROLE_CHOICES = [
        ('CLIENT', 'Client'),
        ('COURIER', 'Livreur'),
        ('ADMIN', 'Administrateur'),
    ]

    role = models.CharField(
        max_length=20,
        choices=ROLE_CHOICES,
        default='CLIENT'
    )

    phone_number = models.CharField(
        max_length=20,
        blank=True,
        null=True
    )

    def __str__(self):
        return f"{self.username} ({self.role})"
