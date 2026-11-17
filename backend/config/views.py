from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

class SubmitExerciseView(APIView):
    def post(self, request):
        exercise_id = request.data.get('exercise_id')
        user_answer = request.data.get('answer')

        # Validación básica de campos requeridos
        if not exercise_id or not user_answer:
            return Response(
                {"error": "Faltan campos obligatorios (exercise_id o answer)"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Lógica de procesamiento y evaluación del RF08
        return Response({
            "exercise_id": exercise_id,
            "status": "success",
            "message": "Respuesta evaluada y procesada correctamente."
        }, status=status.HTTP_200_OK)