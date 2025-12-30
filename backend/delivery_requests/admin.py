from django.contrib import admin
from .models import DeliveryRequest


@admin.register(DeliveryRequest)
class DeliveryRequestAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'client',
        'product_type',
        'pickup_address',
        'delivery_address',
        'status',
        'created_at',
    )

    list_filter = ('status', 'created_at')
    search_fields = ('client__username', 'product_type')
    ordering = ('-created_at',)
