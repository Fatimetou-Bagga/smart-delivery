import random
from django.core.mail import send_mail
from django.conf import settings
from accounts.models import EmailOTP


def generate_otp_code() -> str:
    return f"{random.randint(0, 999999):06d}"


def send_otp_email(user) -> None:
    code = generate_otp_code()
    EmailOTP.objects.create(
        user=user,
        code=code,
        expires_at=EmailOTP.default_expiry(),
    )

    send_mail(
        subject="Smart Delivery - Email Verification Code",
        message=f"Your OTP code is: {code}\nThis code expires in 10 minutes.",
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[user.email],
        fail_silently=False,
    )
