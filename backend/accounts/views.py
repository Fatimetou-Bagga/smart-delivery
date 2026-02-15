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

from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status

from accounts.models import User
from accounts.otp_utils import send_otp_email

from django.utils import timezone
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status

from accounts.models import User, EmailOTP


class VerifyOTPView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get("email")
        code = request.data.get("code")

        if not email or not code:
            return Response({"detail": "email and code are required"}, status=400)

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({"detail": "Invalid email"}, status=400)

        otp = EmailOTP.objects.filter(user=user, code=code, used=False).order_by("-created_at").first()
        if not otp:
            return Response({"detail": "Invalid OTP"}, status=400)

        if otp.expires_at < timezone.now():
            return Response({"detail": "OTP expired"}, status=400)

        otp.used = True
        otp.save(update_fields=["used"])

        user.is_email_verified = True
        user.save(update_fields=["is_email_verified"])

        return Response({"detail": "Email verified successfully"}, status=status.HTTP_200_OK)


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        # Example fields - adapt to your serializer if you use one
        email = request.data.get("email")
        password = request.data.get("password")
        username = request.data.get("username") or email

        if not email or not password:
            return Response({"detail": "email and password are required"}, status=400)

        if User.objects.filter(email=email).exists():
            return Response({"detail": "Email already exists"}, status=400)

        user = User.objects.create_user(
            username=username,
            email=email,
            password=password,
            role="CLIENT",
        )

        user.is_email_verified = False
        user.save(update_fields=["is_email_verified"])

        # Send OTP email
        send_otp_email(user)

        return Response(
            {"detail": "User created. OTP sent to email.", "email": user.email},
            status=status.HTTP_201_CREATED
        )

class CreateCourierView(generics.CreateAPIView):
    """
    Création d’un compte chauffeur (COURIER)
    Accès réservé à l’ADMIN
    """
    serializer_class = CreateCourierSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]

    def perform_create(self, serializer):
        user = serializer.save()
        user.role = "COURIER"
        user.is_email_verified = True
        user.save(update_fields=["role", "is_email_verified"])


class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)