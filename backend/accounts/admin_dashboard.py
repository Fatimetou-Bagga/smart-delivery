from django.contrib.admin.views.decorators import staff_member_required
from django.shortcuts import render
from django.db.models import Count
from accounts.models import User
from delivery_requests.models import DeliveryRequest
from delivery.models import Delivery

@staff_member_required
def dashboard(request):
    users_by_role = list(User.objects.values("role").annotate(count=Count("id")).order_by("role"))
    dr_by_status = list(DeliveryRequest.objects.values("status").annotate(count=Count("id")).order_by("status"))
    del_by_status = list(Delivery.objects.values("status").annotate(count=Count("id")).order_by("status"))

    context = {
        "users_total": User.objects.count(),
        "delivery_requests_total": DeliveryRequest.objects.count(),
        "deliveries_total": Delivery.objects.count(),
        "users_by_role": users_by_role,
        "dr_by_status": dr_by_status,
        "del_by_status": del_by_status,
    }
    return render(request, "admin/dashboard.html", context)
