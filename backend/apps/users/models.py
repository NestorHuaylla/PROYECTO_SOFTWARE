from django.db import models


class ZonaLogica(models.Model):
    id_zona = models.AutoField(primary_key=True)
    codigo_zona = models.CharField(unique=True, max_length=20, blank=True, null=True)
    nombre_zona = models.CharField(unique=True, max_length=100)
    provincia_referencia = models.CharField(max_length=80, blank=True, null=True)
    descripcion = models.CharField(max_length=255, blank=True, null=True)
    activa = models.BooleanField(default=True, blank=True, null=True)
    fecha_creacion = models.DateTimeField(auto_now_add=True, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'zona_logica'

    def __str__(self):
        return f'{self.codigo_zona or ""} - {self.nombre_zona}'.strip(' -')


class Usuario(models.Model):
    id_usuario = models.AutoField(primary_key=True)
    identificador = models.CharField(unique=True, max_length=50, blank=True, null=True)
    alias = models.CharField(unique=True, max_length=50)
    password_hash = models.CharField(max_length=255, blank=True, null=True)
    rol = models.CharField(max_length=20, default='ESTUDIANTE', blank=True, null=True)
    esta_activo = models.BooleanField(default=True, blank=True, null=True)
    ultimo_login = models.DateTimeField(blank=True, null=True)
    fecha_creacion = models.DateTimeField(auto_now_add=True, blank=True, null=True)
    fecha_actualizacion = models.DateTimeField(auto_now=True, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'usuario'

    def __str__(self):
        return f'{self.identificador or self.alias} ({self.rol})'


class PerfilEstudiante(models.Model):
    id_perfil = models.AutoField(primary_key=True)
    id_usuario = models.OneToOneField(
        Usuario,
        on_delete=models.DO_NOTHING,
        db_column='id_usuario',
        blank=True,
        null=True,
    )
    id_zona = models.ForeignKey(
        ZonaLogica,
        on_delete=models.DO_NOTHING,
        db_column='id_zona',
        blank=True,
        null=True,
    )
    nivel_actual = models.ForeignKey(
        'gamification.ReglaNivel',
        on_delete=models.DO_NOTHING,
        db_column='nivel_actual',
        blank=True,
        null=True,
    )
    puntos_totales = models.IntegerField(default=0, blank=True, null=True)
    racha_actual_dias = models.IntegerField(default=0, blank=True, null=True)
    racha_maxima_dias = models.IntegerField(default=0, blank=True, null=True)
    ultima_fecha_racha_lima = models.DateField(blank=True, null=True)
    intereses_analogias = models.CharField(max_length=255, blank=True, null=True)
    grado_escolar = models.CharField(max_length=30, blank=True, null=True)
    fecha_creacion = models.DateTimeField(auto_now_add=True, blank=True, null=True)
    fecha_actualizacion = models.DateTimeField(auto_now=True, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'perfil_estudiante'

    def __str__(self):
        return f'Perfil #{self.id_perfil} ({self.id_usuario})'