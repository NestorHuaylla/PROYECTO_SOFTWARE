from django.db import models

class Exercise(models.Model):
    exercise_id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=255)
    description = models.TextField()
    expected_solution = models.TextField()  # Solución correcta para contrastar
    points = models.IntegerField(default=10)

    class Meta:
        db_table = 'exercises_rf08_structure'