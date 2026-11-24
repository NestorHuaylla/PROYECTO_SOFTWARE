from django.db import models


class ReglaNivel(models.Model):
    nivel = models.IntegerField(primary_key=True)
    nombre_rango = models.CharField(max_length=60, blank=True, null=True)
    puntos_minimos_requeridos = models.IntegerField(blank=True, null=True)
    descripcion_insignia = models.CharField(max_length=150, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'regla_nivel'

    def __str__(self):
        return f'Nivel {self.nivel}: {self.nombre_rango}'


class ActividadDiariaRacha(models.Model):
    id_actividad_racha = models.AutoField(primary_key=True)
    id_perfil = models.ForeignKey(
        'users.PerfilEstudiante',
        on_delete=models.DO_NOTHING,
        db_column='id_perfil',
        blank=True,
        null=True,
    )
    fecha_lima = models.DateField(blank=True, null=True)
    cantidad_ejercicios_dia = models.IntegerField(default=0, blank=True, null=True)
    primer_registro_dia = models.DateTimeField(blank=True, null=True)
    ultimo_registro_dia = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'actividad_diaria_racha'


class HistorialPuntos(models.Model):
    id_transaccion = models.AutoField(primary_key=True)
    id_perfil = models.ForeignKey(
        'users.PerfilEstudiante',
        on_delete=models.DO_NOTHING,
        db_column='id_perfil',
        blank=True,
        null=True,
    )
    tipo_evento = models.CharField(max_length=40, blank=True, null=True)
    evento_origen_key = models.CharField(max_length=100, blank=True, null=True)
    puntos_otorgados = models.IntegerField(blank=True, null=True)
    descripcion = models.CharField(max_length=255, blank=True, null=True)
    fecha_registro = models.DateTimeField(auto_now_add=True, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'historial_puntos'