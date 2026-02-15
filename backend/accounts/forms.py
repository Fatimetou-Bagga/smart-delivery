from django import forms
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError

from accounts.models import User
from delivery_requests.models import DeliveryRequest


class CourierCreateForm(forms.Form):
    username = forms.CharField(max_length=150, widget=forms.TextInput(attrs={"placeholder": "courier_username"}))
    email = forms.EmailField(required=False, widget=forms.EmailInput(attrs={"placeholder": "courier@email.com"}))
    phone_number = forms.CharField(required=False, widget=forms.TextInput(attrs={"placeholder": "+212..." }))
    password1 = forms.CharField(widget=forms.PasswordInput(attrs={"placeholder": "Password"}))
    password2 = forms.CharField(widget=forms.PasswordInput(attrs={"placeholder": "Repeat password"}))

    def clean_username(self):
        username = self.cleaned_data["username"].strip()
        if User.objects.filter(username=username).exists():
            raise ValidationError("This username already exists.")
        return username

    def clean_password1(self):
        pw = self.cleaned_data.get("password1")
        validate_password(pw)
        return pw

    def clean(self):
        cleaned = super().clean()
        p1 = cleaned.get("password1")
        p2 = cleaned.get("password2")
        if p1 and p2 and p1 != p2:
            raise ValidationError("Passwords do not match.")
        return cleaned


class AssignCourierForm(forms.Form):
    delivery_request = forms.ModelChoiceField(
        queryset=DeliveryRequest.objects.none(),
        empty_label="Select a request",
        widget=forms.Select()
    )
    courier = forms.ModelChoiceField(
        queryset=User.objects.none(),
        empty_label="Select a courier",
        widget=forms.Select()
    )

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Only requests without an existing Delivery
        self.fields["delivery_request"].queryset = (
            DeliveryRequest.objects.filter(delivery__isnull=True).order_by("-id")
        )
        self.fields["courier"].queryset = (
            User.objects.filter(role="COURIER", is_active=True).order_by("username")
        )
