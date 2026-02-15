from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.contrib.admin.views.decorators import staff_member_required
from django.utils import timezone
from django.db.models import Count, Q
from datetime import timedelta
from django.views.decorators.http import require_http_methods

from delivery.models import Delivery

from accounts.forms import CourierCreateForm, AssignCourierForm
from accounts.models import User
from delivery_requests.models import DeliveryRequest
from delivery.models import Delivery

def custom_404(request, exception=None):
    return render(request, "404.html", status=404)


@staff_member_required
def dashboard(request):
    now = timezone.now()
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    last_7_days = now - timedelta(days=7)

    # KPIs
    users_total = User.objects.count()
    couriers_total = User.objects.filter(role="COURIER").count()
    clients_total = User.objects.filter(role="CLIENT").count()

    dr_total = DeliveryRequest.objects.count()
    dr_today = DeliveryRequest.objects.filter(created_at__gte=today_start).count()
    dr_last_7 = DeliveryRequest.objects.filter(created_at__gte=last_7_days).count()

    deliveries_total = Delivery.objects.count()
    deliveries_active = Delivery.objects.filter(status__in=["ASSIGNED", "IN_PROGRESS"]).count()

    # Chart data
    users_by_role = list(
        User.objects.values("role").annotate(count=Count("id")).order_by("role")
    )
    dr_by_status = list(
        DeliveryRequest.objects.values("status").annotate(count=Count("id")).order_by("status")
    )
    del_by_status = list(
        Delivery.objects.values("status").annotate(count=Count("id")).order_by("status")
    )

    # Recent activity tables
    recent_requests = list(
        DeliveryRequest.objects.select_related("client")
        .order_by("-created_at")[:10]
        .values("id", "status", "created_at", "client__email")
    )

    recent_deliveries = list(
        Delivery.objects.select_related("courier", "delivery_request")
        .order_by("-assigned_at")[:10]
        .values("id", "status", "assigned_at", "courier__email", "delivery_request_id")
    )

    context = {
        # KPIs
        "users_total": users_total,
        "couriers_total": couriers_total,
        "clients_total": clients_total,
        "dr_total": dr_total,
        "dr_today": dr_today,
        "dr_last_7": dr_last_7,
        "deliveries_total": deliveries_total,
        "deliveries_active": deliveries_active,

        # Charts
        "users_by_role": users_by_role,
        "dr_by_status": dr_by_status,
        "del_by_status": del_by_status,

        # Tables
        "recent_requests": recent_requests,
        "recent_deliveries": recent_deliveries,
    }
    return render(request, "admin/dashboard.html", context)


@staff_member_required
@require_http_methods(["GET", "POST"])
def create_courier_page(request):
    # Optional extra check (your User model has role)
    if getattr(request.user, "role", "") != "ADMIN":
        messages.error(request, "Access denied.")
        return redirect("/admin/dashboard/")

    form = CourierCreateForm(request.POST or None)
    if request.method == "POST" and form.is_valid():
        u = User.objects.create_user(
            username=form.cleaned_data["username"],
            email=form.cleaned_data.get("email") or "",
            phone_number=form.cleaned_data.get("phone_number") or "",
            password=form.cleaned_data["password1"],
            role="COURIER",
        )
        u.is_email_verified = True
        u.is_active = True
        u.save(update_fields=["is_email_verified", "is_active"])
        messages.success(request, f"Courier '{u.username}' created.")
        return redirect("/admin/users/?role=COURIER")

    return render(request, "adminpanel/create_courier.html", {"form": form, "active": "create"})


@staff_member_required
@require_http_methods(["GET", "POST"])
def assign_courier_page(request):
    if getattr(request.user, "role", "") != "ADMIN":
        messages.error(request, "Access denied.")
        return redirect("/admin/dashboard/")

    form = AssignCourierForm(request.POST or None)

    if request.method == "POST" and form.is_valid():
        dr = form.cleaned_data["delivery_request"]
        courier = form.cleaned_data["courier"]

        # Create or update Delivery
        delivery, created = Delivery.objects.get_or_create(
            delivery_request=dr,
            defaults={"courier": courier, "status": "ASSIGNED"},
        )
        if not created:
            delivery.courier = courier
            delivery.status = "ASSIGNED"
            delivery.save(update_fields=["courier", "status"])

        # Keep the request in a consistent state
        if dr.status == "PENDING":
            dr.status = "ACCEPTED"
            dr.save(update_fields=["status"])

        messages.success(request, f"Request #{dr.id} assigned to '{courier.username}'.")
        return redirect("/admin/assign-courier/")

    unassigned = DeliveryRequest.objects.filter(delivery__isnull=True).order_by("-id")[:25]
    return render(
        request,
        "adminpanel/assign_courier.html",
        {"form": form, "unassigned": unassigned, "active": "assign"},
    )


@staff_member_required
@require_http_methods(["GET", "POST"])
def users_manage_page(request):
    if getattr(request.user, "role", "") != "ADMIN":
        messages.error(request, "Access denied.")
        return redirect("/admin/dashboard/")

    if request.method == "POST":
        user_id = request.POST.get("user_id")
        action = request.POST.get("action")
        u = get_object_or_404(User, pk=user_id)

        # Safety: don't let admin lock themselves out accidentally
        if u.pk == request.user.pk and action in {"suspend", "delete"}:
            messages.error(request, "You can't suspend/delete your own account.")
            return redirect("/admin/users/")

        if action == "suspend":
            u.is_active = False
            u.save(update_fields=["is_active"])
            messages.success(request, f"User '{u.username}' suspended.")
        elif action == "activate":
            u.is_active = True
            u.save(update_fields=["is_active"])
            messages.success(request, f"User '{u.username}' activated.")
        elif action == "delete":
            u.delete()
            messages.success(request, "User deleted.")
        else:
            messages.error(request, "Invalid action.")
        return redirect(request.path + ("?" + request.META.get("QUERY_STRING", "") if request.META.get("QUERY_STRING") else ""))

    role = request.GET.get("role") or ""
    q = (request.GET.get("q") or "").strip()

    qs = User.objects.all().order_by("-id")
    if role:
        qs = qs.filter(role=role)
    if q:
        qs = qs.filter(Q(username__icontains=q) | Q(email__icontains=q))

    return render(
        request,
        "adminpanel/users.html",
        {"users": qs[:300], "role": role, "q": q, "active": "users"},
    )
