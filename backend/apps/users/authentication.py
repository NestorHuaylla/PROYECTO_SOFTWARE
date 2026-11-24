from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken
from rest_framework_simplejwt.settings import api_settings

from .models import Usuario


class UsuarioJWTAuthentication(JWTAuthentication):
    """
    Valida el token JWT y busca al dueño en la tabla real `usuario` de PostgreSQL
    (en lugar de la tabla `auth_user` que Django trae por defecto).
    """

    def get_user(self, validated_token):
        try:
            user_id = validated_token[api_settings.USER_ID_CLAIM]
        except KeyError:
            raise InvalidToken('El token no contiene la identificación del usuario.')

        try:
            usuario = Usuario.objects.get(id_usuario=user_id)
        except Usuario.DoesNotExist:
            raise AuthenticationFailed('Usuario no encontrado.', code='user_not_found')

        if usuario.esta_activo is False:
            raise AuthenticationFailed('Esta cuenta está desactivada.', code='user_inactive')

        # Necesario porque `Usuario` hereda de `models.Model` y DRF verifica `is_authenticated`
        usuario.is_authenticated = True
        return usuario