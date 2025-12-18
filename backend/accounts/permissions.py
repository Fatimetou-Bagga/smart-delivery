from rest_framework.permissions import BasePermission


class IsClient(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'CLIENT'


class IsCourier(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'COURIER'


class IsAdmin(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'ADMIN'
