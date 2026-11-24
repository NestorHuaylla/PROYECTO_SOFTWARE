from django.urls import path

from .views import LoginView, MeView, RefreshView, RegisterView

urlpatterns = [
    path('auth/register/', RegisterView.as_view(), name='auth_register'),
    path('auth/login/', LoginView.as_view(), name='auth_login'),
    path('auth/refresh/', RefreshView.as_view(), name='auth_refresh'),
    path('users/me/', MeView.as_view(), name='users_me'),
]