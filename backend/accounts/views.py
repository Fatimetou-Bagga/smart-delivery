from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets, permissions
from .models import User
from .serializers import UserSerializer
from rest_framework.permissions import IsAuthenticated

class UserViewSet(viewsets.ReadOnlyModelViewSet):

    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

