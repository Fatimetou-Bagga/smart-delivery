from django.utils import timezone
from datetime import timedelta
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from accounts.permissions import IsAdmin
from accounts.models import User
from delivery_requests.models import DeliveryRequest
from delivery.models import Delivery


class AdminOverviewStats(APIView):
    permission_classes = [IsAuthenticated, IsAdmin]

    def get(self, request):
        now = timezone.now()
        today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        last_7_days = now - timedelta(days=7)

        users_total = User.objects.count()
        users_by_role = (
            User.objects.values('role')
            .order_by('role')
            .annotate(count=__import__('django.db.models').db.models.Count('id'))
        )

        dr_total = DeliveryRequest.objects.count()
        dr_by_status = (
            DeliveryRequest.objects.values('status')
            .order_by('status')
            .annotate(count=__import__('django.db.models').db.models.Count('id'))
        )
        dr_today = DeliveryRequest.objects.filter(created_at__gte=today_start).count()
        dr_last_7_days = DeliveryRequest.objects.filter(created_at__gte=last_7_days).count()

        deliveries_total = Delivery.objects.count()
        deliveries_by_status = (
            Delivery.objects.values('status')
            .order_by('status')
            .annotate(count=__import__('django.db.models').db.models.Count('id'))
        )

        recent_requests = list(
            DeliveryRequest.objects.select_related('client')
            .order_by('-created_at')[:10]
            .values('id', 'status', 'created_at', 'client__email')
        )

        return Response({
            "users": {
                "total": users_total,
                "by_role": list(users_by_role),
            },
            "delivery_requests": {
                "total": dr_total,
                "today": dr_today,
                "last_7_days": dr_last_7_days,
                "by_status": list(dr_by_status),
                "recent": recent_requests,
            },
            "deliveries": {
                "total": deliveries_total,
                "by_status": list(deliveries_by_status),
            },
        })
