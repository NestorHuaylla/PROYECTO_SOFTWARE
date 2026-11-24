from django.db import models


class ConfigOponenteSimulado(models.Model):
    id_bot = models.AutoField(primary_key=True)
    alias_visible = models.CharField(max_length=60, blank=True, null=True)
    nivel_dificultad = models.IntegerField(blank=True, null=True)
    probabilidad_acierto = models.DecimalField(max_digits=4, decimal_places=2, blank=True, null=True)
    tiempo_respuesta_min_seg = models.IntegerField(blank=True, null=True)
    tiempo_respuesta_max_seg = models.IntegerField(blank=True, null=True)
    activo = models.BooleanField(default=True, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'config_oponente_simulado'


class SesionRetoArena(models.Model):
    id_sesion = models.AutoField(primary_key=True)
    codigo_sala = models.UUIDField(blank=True, null=True)
    id_zona = models.ForeignKey(
        'users.ZonaLogica',
        on_delete=models.DO_NOTHING,
        db_column='id_zona',
        blank=True,
        null=True,
    )
    id_tema = models.ForeignKey(
        'learning.Tema',
        on_delete=models.DO_NOTHING,
        db_column='id_tema',
        blank=True,
        null=True,
    )
    nivel_reto = models.IntegerField(blank=True, null=True)
    id_estudiante_1 = models.ForeignKey(
        'users.PerfilEstudiante',
        on_delete=models.DO_NOTHING,
        db_column='id_estudiante_1',
        related_name='sesiones_como_est_1',
        blank=True,
        null=True,
    )
    id_estudiante_2 = models.ForeignKey(
        'users.PerfilEstudiante',
        on_delete=models.DO_NOTHING,
        db_column='id_estudiante_2',
        related_name='sesiones_como_est_2',
        blank=True,
        null=True,
    )
    es_oponente_simulado = models.BooleanField(default=False, blank=True, null=True)
    id_bot = models.ForeignKey(
        ConfigOponenteSimulado,
        on_delete=models.DO_NOTHING,
        db_column='id_bot',
        blank=True,
        null=True,
    )
    puntaje_est_1 = models.IntegerField(default=0, blank=True, null=True)
    puntaje_est_2 = models.IntegerField(default=0, blank=True, null=True)
    id_ganador = models.ForeignKey(
        'users.PerfilEstudiante',
        on_delete=models.DO_NOTHING,
        db_column='id_ganador',
        related_name='sesiones_ganadas',
        blank=True,
        null=True,
    )
    estado_sesion = models.CharField(max_length=25, blank=True, null=True)
    tiempo_espera_max_seg = models.IntegerField(blank=True, null=True)
    fecha_creacion = models.DateTimeField(auto_now_add=True, blank=True, null=True)
    fecha_inicio = models.DateTimeField(blank=True, null=True)
    fecha_cierre = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'sesion_reto_arena'


class SesionRetoPregunta(models.Model):
    id_sesion_pregunta = models.AutoField(primary_key=True)
    id_sesion = models.ForeignKey(
        SesionRetoArena,
        on_delete=models.DO_NOTHING,
        db_column='id_sesion',
        blank=True,
        null=True,
    )
    id_ejercicio = models.ForeignKey(
        'learning.Ejercicio',
        on_delete=models.DO_NOTHING,
        db_column='id_ejercicio',
        blank=True,
        null=True,
    )
    numero_orden = models.IntegerField(blank=True, null=True)
    tiempo_maximo_seg = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'sesion_reto_pregunta'


class RespuestaRetoArena(models.Model):
    id_respuesta_reto = models.AutoField(primary_key=True)
    id_sesion_pregunta = models.ForeignKey(
        SesionRetoPregunta,
        on_delete=models.DO_NOTHING,
        db_column='id_sesion_pregunta',
        blank=True,
        null=True,
    )
    id_perfil = models.ForeignKey(
        'users.PerfilEstudiante',
        on_delete=models.DO_NOTHING,
        db_column='id_perfil',
        blank=True,
        null=True,
    )
    es_respuesta_bot = models.BooleanField(default=False, blank=True, null=True)
    client_request_uuid = models.UUIDField(blank=True, null=True)
    respuesta_enviada = models.CharField(max_length=255, blank=True, null=True)
    es_correcta = models.BooleanField(blank=True, null=True)
    dentro_de_tiempo = models.BooleanField(blank=True, null=True)
    tiempo_respuesta_ms = models.IntegerField(blank=True, null=True)
    puntos_ganados = models.IntegerField(default=0, blank=True, null=True)
    fecha_servidor = models.DateTimeField(auto_now_add=True, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'respuesta_reto_arena'