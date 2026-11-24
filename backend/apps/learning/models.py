from django.db import models


class Tema(models.Model):
    id_tema = models.AutoField(primary_key=True)
    codigo_tema = models.CharField(unique=True, max_length=30, blank=True, null=True)
    nombre = models.CharField(max_length=120)
    area_curricular = models.CharField(max_length=60, blank=True, null=True)
    nivel_dificultad = models.IntegerField(blank=True, null=True)
    descripcion = models.TextField(blank=True, null=True)
    activo = models.BooleanField(default=True, blank=True, null=True)
    revisado_docente = models.BooleanField(default=False, blank=True, null=True)
    id_creador = models.ForeignKey(
        'users.Usuario',
        on_delete=models.DO_NOTHING,
        db_column='id_creador',
        blank=True,
        null=True,
    )
    fecha_creacion = models.DateTimeField(auto_now_add=True, blank=True, null=True)
    fecha_actualizacion = models.DateTimeField(auto_now=True, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'tema'

    def __str__(self):
        return self.nombre


class Microleccion(models.Model):
    id_microleccion = models.AutoField(primary_key=True)
    id_tema = models.ForeignKey(
        Tema,
        on_delete=models.DO_NOTHING,
        db_column='id_tema',
        blank=True,
        null=True,
    )
    titulo = models.CharField(max_length=150)
    contenido_explicacion = models.TextField(blank=True, null=True)
    analogia_base = models.TextField(blank=True, null=True)
    recurso_visual_url = models.CharField(max_length=255, blank=True, null=True)
    orden_secuencia = models.IntegerField(blank=True, null=True)
    tiempo_lectura_estimado_seg = models.IntegerField(blank=True, null=True)
    publicada = models.BooleanField(default=True, blank=True, null=True)
    fecha_creacion = models.DateTimeField(auto_now_add=True, blank=True, null=True)
    fecha_actualizacion = models.DateTimeField(auto_now=True, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'microleccion'

    def __str__(self):
        return self.titulo


class Ejercicio(models.Model):
    id_ejercicio = models.AutoField(primary_key=True)
    id_microleccion = models.ForeignKey(
        Microleccion,
        on_delete=models.DO_NOTHING,
        db_column='id_microleccion',
        blank=True,
        null=True,
    )
    tipo_ejercicio = models.CharField(max_length=30, blank=True, null=True)
    enunciado = models.TextField()
    recurso_grafico_url = models.CharField(max_length=255, blank=True, null=True)
    solucion_correcta = models.CharField(max_length=255, blank=True, null=True)
    explicacion_retroalimentacion = models.TextField(blank=True, null=True)
    tiempo_limite_seg = models.IntegerField(blank=True, null=True)
    puntos_base = models.IntegerField(default=10, blank=True, null=True)
    activo = models.BooleanField(default=True, blank=True, null=True)
    id_creador = models.ForeignKey(
        'users.Usuario',
        on_delete=models.DO_NOTHING,
        db_column='id_creador',
        blank=True,
        null=True,
    )
    fecha_creacion = models.DateTimeField(auto_now_add=True, blank=True, null=True)
    fecha_actualizacion = models.DateTimeField(auto_now=True, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ejercicio'


class OpcionEjercicio(models.Model):
    id_opcion = models.AutoField(primary_key=True)
    id_ejercicio = models.ForeignKey(
        Ejercicio,
        on_delete=models.DO_NOTHING,
        db_column='id_ejercicio',
        blank=True,
        null=True,
    )
    codigo_opcion = models.CharField(max_length=1, blank=True, null=True)
    texto_opcion = models.TextField(blank=True, null=True)
    es_correcta = models.BooleanField(default=False, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'opcion_ejercicio'


class InscripcionTema(models.Model):
    id_inscripcion = models.AutoField(primary_key=True)
    id_perfil = models.ForeignKey(
        'users.PerfilEstudiante',
        on_delete=models.DO_NOTHING,
        db_column='id_perfil',
        blank=True,
        null=True,
    )
    id_tema = models.ForeignKey(
        Tema,
        on_delete=models.DO_NOTHING,
        db_column='id_tema',
        blank=True,
        null=True,
    )
    ejercicios_completados = models.IntegerField(default=0, blank=True, null=True)
    ejercicios_totales_tema = models.IntegerField(default=0, blank=True, null=True)
    porcentaje_avance = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    completado = models.BooleanField(default=False, blank=True, null=True)
    fecha_eleccion = models.DateTimeField(auto_now_add=True, blank=True, null=True)
    ultima_interaccion = models.DateTimeField(auto_now=True, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'inscripcion_tema'


class IntentoEjercicio(models.Model):
    id_intento = models.AutoField(primary_key=True)
    id_perfil = models.ForeignKey(
        'users.PerfilEstudiante',
        on_delete=models.DO_NOTHING,
        db_column='id_perfil',
        blank=True,
        null=True,
    )
    id_ejercicio = models.ForeignKey(
        Ejercicio,
        on_delete=models.DO_NOTHING,
        db_column='id_ejercicio',
        blank=True,
        null=True,
    )
    client_request_uuid = models.UUIDField(blank=True, null=True)
    respuesta_enviada = models.CharField(max_length=255, blank=True, null=True)
    es_correcta = models.BooleanField(blank=True, null=True)
    puntos_otorgados = models.IntegerField(default=0, blank=True, null=True)
    tiempo_resolucion_seg = models.IntegerField(blank=True, null=True)
    fecha_intento = models.DateTimeField(auto_now_add=True, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'intento_ejercicio'