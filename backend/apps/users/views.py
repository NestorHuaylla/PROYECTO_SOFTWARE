from django.contrib.auth.hashers import check_password, make_password
from django.db import IntegrityError, transaction
from django.db.models import Q
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.settings import api_settings
from rest_framework_simplejwt.tokens import RefreshToken

from apps.gamification.models import ReglaNivel

from .models import PerfilEstudiante, Usuario
from .serializers import (
    LoginSerializer,
    RefreshSerializer,
    RegisterSerializer,
    UsuarioPerfilSerializer,
)


def generar_tokens(usuario):
    """Genera el par de tokens JWT (access + refresh) para un Usuario de KADIR."""
    refresh = RefreshToken.for_user(usuario)
    return {
        'access': str(refresh.access_token),
        'refresh': str(refresh),
    }


class RegisterView(APIView):
    """POST /api/auth/register/ -> crea Usuario + PerfilEstudiante y devuelve tokens."""

    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        datos = serializer.validated_data

        try:
            with transaction.atomic():
                usuario = Usuario.objects.create(
                    identificador=datos['identificador'],
                    alias=datos['alias'],
                    password_hash=make_password(datos['password']),
                    rol='ESTUDIANTE',
                    esta_activo=True,
                )
                nivel_inicial = ReglaNivel.objects.order_by('nivel').first()
                if nivel_inicial is None:
                    nivel_inicial = ReglaNivel.objects.create(
                        nivel=1,
                        nombre_rango='Inicial',
                        puntos_minimos_requeridos=0,
                        descripcion_insignia='Nivel inicial de KADIR',
                    )
                PerfilEstudiante.objects.create(
                    id_usuario=usuario,
                    nivel_actual=nivel_inicial,
                    puntos_totales=0,
                    racha_actual_dias=0,
                    racha_maxima_dias=0,
                )
        except IntegrityError:
            return Response(
                {'error': 'El identificador o el alias ya están registrados.'},
                status=status.HTTP_409_CONFLICT,
            )

        return Response(
            {
                'mensaje': 'Cuenta creada correctamente.',
                'usuario': UsuarioPerfilSerializer(usuario).data,
                'tokens': generar_tokens(usuario),
            },
            status=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    """POST /api/auth/login/ -> valida credenciales y devuelve tokens."""

    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        identificador = serializer.validated_data['identificador'].strip()
        password = serializer.validated_data['password']

        sin_arroba = identificador.lstrip('@')
        usuario = (
            Usuario.objects.filter(
                Q(identificador__iexact=f'@{sin_arroba}')
                | Q(identificador__iexact=sin_arroba)
                | Q(alias__iexact=identificador)
            )
            .order_by('id_usuario')
            .first()
        )

        credenciales_ok = (
            usuario is not None
            and bool(usuario.password_hash)
            and check_password(password, usuario.password_hash)
        )
        if not credenciales_ok:
            return Response(
                {'error': 'Identificador o contraseña incorrectos.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        if usuario.esta_activo is False:
            return Response(
                {'error': 'Esta cuenta está desactivada.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        ahora = timezone.now()
        Usuario.objects.filter(pk=usuario.pk).update(ultimo_login=ahora)
        usuario.ultimo_login = ahora

        return Response(
            {
                'mensaje': 'Inicio de sesión exitoso.',
                'usuario': UsuarioPerfilSerializer(usuario).data,
                'tokens': generar_tokens(usuario),
            },
            status=status.HTTP_200_OK,
        )


class RefreshView(APIView):
    """POST /api/auth/refresh/ -> entrega un nuevo access token usando el refresh."""

    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RefreshSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            refresh = RefreshToken(serializer.validated_data['refresh'])
        except TokenError:
            return Response(
                {'error': 'La sesión expiró. Vuelve a iniciar sesión.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        user_id = refresh.payload.get(api_settings.USER_ID_CLAIM)
        existe = (
            Usuario.objects.filter(id_usuario=user_id)
            .exclude(esta_activo=False)
            .exists()
        )
        if not existe:
            return Response(
                {'error': 'Usuario no encontrado o desactivado.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        return Response({'access': str(refresh.access_token)}, status=status.HTTP_200_OK)


class MeView(APIView):
    """GET /api/users/me/ -> datos del usuario autenticado (Home y Perfil)."""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(UsuarioPerfilSerializer(request.user).data)