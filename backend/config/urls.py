from django.contrib import admin
from django.urls import include, path
from django.views.generic import RedirectView
from accounts.jwt_views import VerifiedTokenObtainPairView

from rest_framework.routers import DefaultRouter
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

from accounts.views import CreateCourierView, MeView, RegisterView, UserViewSet
from delivery.views import DeliveryViewSet
from delivery_requests.views import DeliveryRequestViewSet
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from config.views import dashboard, create_courier_page, assign_courier_page, users_manage_page  # ✅ IMPORTANT
from django.conf import settings
from django.conf.urls.static import static
from accounts.views import VerifyOTPView

schema_view = get_schema_view(
    openapi.Info(
        title="Smart Delivery API",
        default_version="v1",
        description="API de gestion des demandes et livraisons",
        terms_of_service="https://www.google.com/policies/terms/",
        contact=openapi.Contact(email="fatimetou@mail.com"),
        license=openapi.License(name="MIT License"),
    ),
    public=True,
    permission_classes=[permissions.AllowAny],
)

router = DefaultRouter()
router.register(r"users", UserViewSet, basename="user")
router.register(r"delivery-requests", DeliveryRequestViewSet, basename="delivery-request")
router.register(r"deliveries", DeliveryViewSet, basename="delivery")

urlpatterns = [
    # ✅ Default page redirect
    path("", RedirectView.as_view(url="/admin/login/", permanent=False)),

    # ✅ Dashboard MUST be before admin/
    path("admin/dashboard/", dashboard, name="admin-dashboard"),

    # Custom admin panel pages (NOT Django admin)
    path("admin/create-courier/", create_courier_page, name="admin-create-courier-page"),
    path("admin/assign-courier/", assign_courier_page, name="admin-assign-courier-page"),
    path("admin/users/", users_manage_page, name="admin-users-manage-page"),

    # Django admin
    path("admin/", admin.site.urls),

    # Auth routes
    path("api/auth/register/", RegisterView.as_view(), name="register"),
    path("api/auth/login/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/auth/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("api/admin/create-courier/", CreateCourierView.as_view(), name="create-courier"),
    path("api/auth/me/", MeView.as_view(), name="auth-me"),
    path("api/auth/verify-otp/", VerifyOTPView.as_view(), name="verify-otp"),
    # API router
    path("api/", include(router.urls)),

    # Docs
    path("swagger/", schema_view.with_ui("swagger", cache_timeout=0), name="schema-swagger-ui"),
    path("redoc/", schema_view.with_ui("redoc", cache_timeout=0), name="schema-redoc"),
]

handler404 = "config.views.custom_404"


urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)


path("api/auth/login/", VerifiedTokenObtainPairView.as_view(), name="token_obtain_pair"),
