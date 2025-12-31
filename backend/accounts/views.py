from django.shortcuts import render
from rest_framework.response import Response

# Create your views here.
from rest_framework import viewsets, permissions
from rest_framework.views import APIView
from accounts.permissions import IsAdmin
from .models import User
from .serializers import CreateCourierSerializer, RegisterSerializer, UserSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework import generics, permissions
class UserViewSet(viewsets.ReadOnlyModelViewSet):

    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

class RegisterView(generics.CreateAPIView):
    """
    Inscription des utilisateurs (CLIENT uniquement)
    """
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]

class CreateCourierView(generics.CreateAPIView):
    """
    Création d’un compte chauffeur (COURIER)
    Accès réservé à l’ADMIN
    """
    serializer_class = CreateCourierSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]    

class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)