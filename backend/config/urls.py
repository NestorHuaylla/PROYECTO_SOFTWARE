from django.contrib import admin
from django.urls import include, path
from .views import SubmitExerciseView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('apps.users.urls')),
    path('api/exercises/submit/', SubmitExerciseView.as_view(), name='exercise_submit'),
]