from django.urls import path
from accounts.views_admin import AdminOverviewStats

urlpatterns = [
    path('admin/stats/overview/', AdminOverviewStats.as_view(), name='admin-overview-stats'),
]
