from django.contrib import admin
from django.urls import path
from .views import SubmitExerciseView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/exercises/submit/', SubmitExerciseView.as_view(), name='exercise_submit'),
]