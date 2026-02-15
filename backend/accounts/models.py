from django.db import models

# Create your models here.
from django.contrib.auth.models import AbstractUser
from django.db import models
import uuid
from datetime import timedelta
from django.conf import settings
from django.db import models
from django.utils import timezone


class User(AbstractUser):
    role = models.CharField(max_length=20)
    is_available = models.BooleanField(default=False)
    is_email_verified = models.BooleanField(default=False)
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


class EmailOTP(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="email_otps")
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    used = models.BooleanField(default=False)
    attempts = models.PositiveIntegerField(default=0)

    @staticmethod
    def default_expiry():
        return timezone.now() + timedelta(minutes=10)