from rest_framework import serializers

from .models import PerfilEstudiante, Usuario


class RegisterSerializer(serializers.Serializer):
    """Valida los datos enviados por RegisterScreen de Flutter."""

    identificador = serializers.CharField(max_length=50)
    alias = serializers.CharField(max_length=50)
    password = serializers.CharField(
        min_length=6,
        max_length=128,
        write_only=True,
        trim_whitespace=False,
    )

    def validate_identificador(self, value):
        limpio = value.strip()
        if not limpio.startswith('@'):
            limpio = f'@{limpio}'

        cuerpo = limpio[1:]
        if len(cuerpo) < 3:
            raise serializers.ValidationError(
                'El identificador debe tener al menos 3 caracteres.'
            )
        if len(limpio) > 50:
            raise serializers.ValidationError(
                'El identificador no puede superar los 50 caracteres.'
            )
        if not all(ch.isalnum() or ch in '._' for ch in cuerpo):
            raise serializers.ValidationError(
                'Usa solo letras, números, punto (.) o guion bajo (_).'
            )
        if Usuario.objects.filter(identificador__iexact=limpio).exists():
            raise serializers.ValidationError('Este identificador ya está registrado.')
        return limpio

    def validate_alias(self, value):
        limpio = value.strip()
        if len(limpio) < 2:
            raise serializers.ValidationError('El alias debe tener al menos 2 caracteres.')
        if Usuario.objects.filter(alias__iexact=limpio).exists():
            raise serializers.ValidationError('Este alias ya está en uso.')
        return limpio


class LoginSerializer(serializers.Serializer):
    """
    Acepta `identificador` o `username` (con o sin `@`, o el alias) más `password`,
    para ser 100% compatible con RegisterScreen y con LoginScreen.
    """

    identificador = serializers.CharField(max_length=60, required=False)
    username = serializers.CharField(max_length=60, required=False, write_only=True)
    password = serializers.CharField(write_only=True, trim_whitespace=False)

    def validate(self, attrs):
        user_input = (attrs.get('identificador') or attrs.get('username') or '').strip()
        if not user_input:
            raise serializers.ValidationError(
                {'identificador': 'Debes enviar tu identificador o usuario.'}
            )
        attrs['identificador'] = user_input
        return attrs


class RefreshSerializer(serializers.Serializer):
    refresh = serializers.CharField()


class UsuarioPerfilSerializer(serializers.ModelSerializer):
    """Respuesta pública del usuario + su perfil (nunca expone password_hash)."""

    perfil = serializers.SerializerMethodField()

    class Meta:
        model = Usuario
        fields = [
            'id_usuario',
            'identificador',
            'alias',
            'rol',
            'esta_activo',
            'ultimo_login',
            'fecha_creacion',
            'perfil',
        ]

    def get_perfil(self, usuario):
        perfil = (
            PerfilEstudiante.objects.select_related('id_zona', 'nivel_actual')
            .filter(id_usuario=usuario)
            .first()
        )
        if perfil is None:
            return None

        nivel = perfil.nivel_actual
        zona = perfil.id_zona
        return {
            'id_perfil': perfil.id_perfil,
            'puntos_totales': perfil.puntos_totales or 0,
            'racha_actual_dias': perfil.racha_actual_dias or 0,
            'racha_maxima_dias': perfil.racha_maxima_dias or 0,
            'ultima_fecha_racha_lima': perfil.ultima_fecha_racha_lima,
            'grado_escolar': perfil.grado_escolar,
            'intereses_analogias': perfil.intereses_analogias,
            'nivel': (
                {'numero': nivel.nivel, 'nombre_rango': nivel.nombre_rango}
                if nivel
                else None
            ),
            'zona': (
                {
                    'id_zona': zona.id_zona,
                    'codigo_zona': zona.codigo_zona,
                    'nombre_zona': zona.nombre_zona,
                }
                if zona
                else None
            ),
        }