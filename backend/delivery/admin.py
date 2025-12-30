from django.contrib import admin
from .models import Delivery


@admin.register(Delivery)
class DeliveryAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'delivery_request',
        'courier',
        'status',
        'assigned_at',
        'delivered_at',
    )

    list_filter = ('status', 'assigned_at')
    search_fields = (
        'courier__username',
        'delivery_request__product_type',
    )
    ordering = ('-assigned_at',)
