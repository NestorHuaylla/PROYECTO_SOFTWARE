from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Exercise

class SubmitExerciseView(APIView):
    def post(self, request):
        exercise_id = request.data.get('exercise_id')
        user_answer = request.data.get('answer')

        # 1. Validación de campos requeridos (Genera la situación de rechazo / Error 400)
        if not exercise_id or not user_answer:
            return Response(
                {"error": "Faltan campos obligatorios (exercise_id o answer)"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            # 2. Conexión y consulta real a la base de datos mediante el ORM de Django
            exercise = Exercise.objects.get(pk=exercise_id)
            
            # 3. Lógica de contraste de la respuesta enviada vs la oficial
            is_correct = (user_answer.strip() == exercise.expected_solution.strip())
            
            return Response({
                "exercise_id": exercise.exercise_id,
                "title": exercise.title,
                "status": "success" if is_correct else "incorrect",
                "message": "Respuesta evaluada y procesada correctamente."
            }, status=status.HTTP_200_OK)

        except Exercise.DoesNotExist:
            # Manejo si el ID no existe en la base de datos (Error 404)
            return Response(
                {"error": "El ejercicio especificado no existe en la base de datos."},
                status=status.HTTP_404_NOT_FOUND
            )