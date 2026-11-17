from django.contrib import admin
from django.urls import path
from config.views import SubmitExerciseView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/exercises/submit/', SubmitExerciseView.as_view(), name='submit_exercise'),
]