import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'modes_screen.dart';

/// ============================================================================
/// 1. MODELOS DE TEMARIO Y ANALOGÍA (4 Fases)
/// ============================================================================

enum KadirStudyFocus { desdeCero, repasoRapido, modoExamen }

extension KadirStudyFocusExt on KadirStudyFocus {
  String get label {
    switch (this) {
      case KadirStudyFocus.desdeCero:
        return 'Desde cero';
      case KadirStudyFocus.repasoRapido:
        return 'Repaso rápido';
      case KadirStudyFocus.modoExamen:
        return 'Modo examen';
    }
  }
}

class KadirSyllabusTopic {
  final String id;
  final KadirAreaId area;
  final String unitNumber;
  final String title;
  final String shortGoal;
  final String durationLabel;
  final String coreConcept;
  final String formulaOrRule;
  final List<String> keySteps;
  final String examplePrompt;
  final String exampleResolution;
  final String checkQuestion;
  final List<String> checkOptions;
  final int correctOptionIndex;
  final String checkExplanation;

  const KadirSyllabusTopic({
    required this.id,
    required this.area,
    required this.unitNumber,
    required this.title,
    required this.shortGoal,
    required this.durationLabel,
    required this.coreConcept,
    required this.formulaOrRule,
    required this.keySteps,
    required this.examplePrompt,
    required this.exampleResolution,
    required this.checkQuestion,
    required this.checkOptions,
    required this.correctOptionIndex,
    required this.checkExplanation,
  });
}

class KadirAnalogyEquivalence {
  final String universeConcept;
  final String realConcept;
  final String shortDesc;

  const KadirAnalogyEquivalence({
    required this.universeConcept,
    required this.realConcept,
    required this.shortDesc,
  });
}

class KadirAnalogyRoute {
  final String topic;
  final String universe;
  final List<KadirAnalogyEquivalence> equivalences;
  final List<String> storyCards;
  final String questionPrompt;
  final List<String> questionOptions;
  final int correctIndex;
  final String questionFeedback;
  final String formalDefinition;
  final String formulaOrRule;

  const KadirAnalogyRoute({
    required this.topic,
    required this.universe,
    required this.equivalences,
    required this.storyCards,
    required this.questionPrompt,
    required this.questionOptions,
    required this.correctIndex,
    required this.questionFeedback,
    required this.formalDefinition,
    required this.formulaOrRule,
  });
}

Color _pAlpha(Color color, double opacity) {
  return color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

/// Catálogo oficial de temas por área (4 temas por cada una de las 3 áreas)
List<KadirSyllabusTopic> getKadirSyllabus(KadirAreaId area) {
  switch (area) {
    case KadirAreaId.logicoMatematico:
      return const [
        KadirSyllabusTopic(
          id: 'lm-01',
          area: KadirAreaId.logicoMatematico,
          unitNumber: '01',
          title: 'Fracciones y proporciones',
          shortGoal: 'Equivalencias, simplificación y regla de tres directa.',
          durationLabel: '5 min',
          coreConcept:
              'Una fracción a/b indica cuántas partes iguales tomas de un total dividido en b partes. Dos razones forman una proporción cuando mantienen exactamente la misma relación al escalar.',
          formulaOrRule: 'a / b = c / d  ⇔  a · d = b · c   (b ≠ 0, d ≠ 0)',
          keySteps: [
            'Identifica el numerador (partes tomadas) y el denominador (total de partes).',
            'Simplifica dividiendo arriba y abajo por su Máximo Común Divisor.',
            'Para hallar una incógnita, aplica producto cruzado y despeja.',
          ],
          examplePrompt:
              'Si 3 cuadernos cuestan S/ 18, ¿cuánto costarán 5 cuadernos iguales?',
          exampleResolution: '3 / 18 = 5 / x → 3x = 90 → x = 90 / 3 = S/ 30.',
          checkQuestion: '¿Cuál es la fracción irreductible equivalente a 24/36?',
          checkOptions: ['4/9', '2/3', '3/4', '6/9'],
          correctOptionIndex: 1,
          checkExplanation:
              'El MCD de 24 y 36 es 12. Al dividir ambos términos entre 12 obtienes 2/3.',
        ),
        KadirSyllabusTopic(
          id: 'lm-02',
          area: KadirAreaId.logicoMatematico,
          unitNumber: '02',
          title: 'Ecuaciones de primer grado',
          shortGoal: 'Despeje de incógnitas, transposición y comprobación.',
          durationLabel: '6 min',
          coreConcept:
              'Una ecuación lineal es una balanza en equilibrio con una incógnita de exponente 1. Todo lo que haces en un lado de la igualdad debes aplicarlo igual en el otro.',
          formulaOrRule: 'ax + b = c  ⇒  x = (c − b) / a   (a ≠ 0)',
          keySteps: [
            'Agrupa los términos con x en un lado y las constantes en el otro.',
            'Reduce términos semejantes en ambos miembros.',
            'Divide por el coeficiente de x y comprueba el resultado.',
          ],
          examplePrompt: 'Resuelve la ecuación: 4x − 7 = 17',
          exampleResolution:
              '4x = 17 + 7 → 4x = 24 → x = 24 / 4 = 6. (Comprobación: 4·6 − 7 = 17).',
          checkQuestion: '¿Qué valor de x satisface la ecuación 3x + 5 = 20?',
          checkOptions: ['x = 4', 'x = 5', 'x = 6', 'x = 8'],
          correctOptionIndex: 1,
          checkExplanation:
              'Restas 5 en ambos lados (3x = 15) y divides entre 3: x = 5.',
        ),
        KadirSyllabusTopic(
          id: 'lm-03',
          area: KadirAreaId.logicoMatematico,
          unitNumber: '03',
          title: 'Porcentajes y variaciones',
          shortGoal: 'Cálculo de descuentos, aumentos y tantos por ciento.',
          durationLabel: '5 min',
          coreConcept:
              'Un porcentaje representa una fracción con denominador 100. Calcular el p% de una cantidad equivale a multiplicarla por p/100.',
          formulaOrRule: 'p% de N = (p / 100) · N',
          keySteps: [
            'Convierte el porcentaje a decimal dividiendo entre 100.',
            'Multiplica el decimal por el valor base.',
            'Suma si es aumento o resta si es descuento respecto al 100% inicial.',
          ],
          examplePrompt:
              'Una mochila de S/ 120 tiene 20% de descuento. ¿Cuánto pagas?',
          exampleResolution:
              'Descuento = 0.20 × 120 = S/ 24. Precio final = 120 − 24 = S/ 96.',
          checkQuestion: '¿Cuánto es el 15% de 200?',
          checkOptions: ['20', '25', '30', '35'],
          correctOptionIndex: 2,
          checkExplanation: '(15 / 100) × 200 = 15 × 2 = 30.',
        ),
        KadirSyllabusTopic(
          id: 'lm-04',
          area: KadirAreaId.logicoMatematico,
          unitNumber: '04',
          title: 'Teorema de Pitágoras',
          shortGoal: 'Relación entre catetos e hipotenusa en triángulos rectángulos.',
          durationLabel: '6 min',
          coreConcept:
              'En todo triángulo rectángulo (con ángulo de 90°), el cuadrado de la hipotenusa es igual a la suma de los cuadrados de los dos catetos.',
          formulaOrRule: 'c² = a² + b²   ⇒   c = √(a² + b²)',
          keySteps: [
            'Ubica el ángulo de 90°: el lado opuesto siempre es la hipotenusa (c).',
            'Eleva al cuadrado las medidas conocidas.',
            'Suma si buscas la hipotenusa o resta si buscas un cateto, y extrae la raíz.',
          ],
          examplePrompt:
              'Un triángulo rectángulo tiene catetos de 6 cm y 8 cm. Halla la hipotenusa.',
          exampleResolution: 'c² = 6² + 8² = 36 + 64 = 100 → c = √100 = 10 cm.',
          checkQuestion:
              'Si los catetos miden 3 m y 4 m, ¿cuánto mide la hipotenusa?',
          checkOptions: ['5 m', '6 m', '7 m', '12 m'],
          correctOptionIndex: 0,
          checkExplanation: 'c = √(3² + 4²) = √(9 + 16) = √25 = 5 m.',
        ),
      ];
    case KadirAreaId.comprensionLectora:
      return const [
        KadirSyllabusTopic(
          id: 'cl-01',
          area: KadirAreaId.comprensionLectora,
          unitNumber: '01',
          title: 'Idea principal e inferencia',
          shortGoal:
              'Separar el mensaje central de los detalles y leer entre líneas.',
          durationLabel: '5 min',
          coreConcept:
              'La idea principal sintetiza qué afirma el texto en esencia. Inferir consiste en deducir una conclusión implícita combinando pistas explícitas con lógica.',
          formulaOrRule:
              'Idea principal = Tema + Afirmación central  |  Inferencia = Pista + Lógica',
          keySteps: [
            'Pregúntate: "¿De qué trata el párrafo y qué es lo más importante que afirma?"',
            'Comprueba jerarquía: sin la idea principal el párrafo pierde sentido.',
            'Valida toda inferencia con una frase explícita del texto.',
          ],
          examplePrompt:
              '"El patio estaba empapado y todos entraron sacudiendo sus paraguas."',
          exampleResolution:
              'Inferencia válida: acaba de llover (respaldada por "empapado" y "paraguas").',
          checkQuestion:
              '¿Qué condición debe cumplir siempre una inferencia correcta?',
          checkOptions: [
            'Repetir palabra por palabra la primera oración.',
            'Apoyarse en pistas reales del texto sin inventar datos.',
            'Expresar únicamente si te gustó la lectura.',
            'Incluir muchos adjetivos.',
          ],
          correctOptionIndex: 1,
          checkExplanation:
              'Inferir requiere deducir a partir de evidencias presentes en el texto.',
        ),
        KadirSyllabusTopic(
          id: 'cl-02',
          area: KadirAreaId.comprensionLectora,
          unitNumber: '02',
          title: 'Texto argumentativo y tesis',
          shortGoal: 'Detectar la postura del autor, sus razones y el respaldo.',
          durationLabel: '6 min',
          coreConcept:
              'Un texto argumentativo defiende una postura (tesis) usando razones verificables o datos (argumentos) y cierra con una conclusión coherente.',
          formulaOrRule: 'Tesis (Postura) + Argumentos (Por qué) + Conclusión',
          keySteps: [
            'Localiza la tesis: es la opinión debatible defendida por el autor.',
            'Distingue los argumentos: responden a "¿por qué afirma eso?".',
            'Identifica contraargumentos con "aunque" o "sin embargo".',
          ],
          examplePrompt:
              '"Dormir 8 horas mejora la memoria escolar, pues reduce 30% los errores."',
          exampleResolution:
              'Tesis: dormir 8 horas mejora la memoria. Argumento: el dato del 30%.',
          checkQuestion:
              '¿Qué elemento expresa la postura central que defiende el autor?',
          checkOptions: [
            'La anécdota inicial',
            'La tesis',
            'La bibliografía',
            'El subtítulo',
          ],
          correctOptionIndex: 1,
          checkExplanation:
              'La tesis es la proposición central que se sostiene con argumentos.',
        ),
        KadirSyllabusTopic(
          id: 'cl-03',
          area: KadirAreaId.comprensionLectora,
          unitNumber: '03',
          title: 'Conectores lógicos y cohesión',
          shortGoal: 'Relaciones de causa, consecuencia, contraste y adición.',
          durationLabel: '5 min',
          coreConcept:
              'Los conectores lógicos unen ideas y revelan su relación exacta: causa ("porque"), consecuencia ("por lo tanto"), contraste ("sin embargo") o adición ("además").',
          formulaOrRule:
              'Causa (porque) · Consecuencia (por ello) · Contraste (pero / aunque)',
          keySteps: [
            'Lee la idea anterior y posterior al conector para identificar su vínculo.',
            'Sustituye por otro conector de la misma familia para confirmar sentido.',
            'No confundas causa ("debido a que") con consecuencia ("por consiguiente").',
          ],
          examplePrompt:
              '"Estudió toda la semana; ______, obtuvo la nota más alta del salón."',
          exampleResolution:
              'La segunda idea es el efecto de la primera → "por lo tanto".',
          checkQuestion:
              '¿Qué tipo de relación establece el conector "sin embargo"?',
          checkOptions: [
            'Causa',
            'Contraste u oposición',
            'Secuencia temporal',
            'Ejemplificación',
          ],
          correctOptionIndex: 1,
          checkExplanation:
              '"Sin embargo" introduce una idea que contrasta o limita lo anterior.',
        ),
        KadirSyllabusTopic(
          id: 'cl-04',
          area: KadirAreaId.comprensionLectora,
          unitNumber: '04',
          title: 'Hecho vs. opinión e intención',
          shortGoal: 'Diferenciar datos comprobables de juicios del autor.',
          durationLabel: '5 min',
          coreConcept:
              'Un hecho es un dato objetivo comprobable como verdadero o falso. Una opinión expresa un juicio o valoración personal del autor.',
          formulaOrRule: 'Hecho = Comprobable  ≠  Opinión = Valoración personal',
          keySteps: [
            'Busca fechas, cifras, mediciones o sucesos verificables (hechos).',
            'Detecta adjetivos valorativos como "mejor", "aburrido" o "injusto" (opiniones).',
            'Identifica si el propósito es informar, persuadir o entretener.',
          ],
          examplePrompt:
              '"La biblioteca abre a las 8:00 a. m. y es el mejor lugar del colegio."',
          exampleResolution:
              'Hecho: "abre a las 8:00 a. m.". Opinión: "es el mejor lugar".',
          checkQuestion: '¿Cuál de los siguientes enunciados es un HECHO?',
          checkOptions: [
            'El invierno es la estación más aburrida.',
            'El agua hierve a 100 °C al nivel del mar.',
            'Las matemáticas deberían durar media hora.',
            'Ese libro tiene el mejor final.',
          ],
          correctOptionIndex: 1,
          checkExplanation:
              'El punto de ebullición del agua a nivel del mar es comprobable objetivamente.',
        ),
      ];
    case KadirAreaId.ciencias:
      return const [
        KadirSyllabusTopic(
          id: 'ci-01',
          area: KadirAreaId.ciencias,
          unitNumber: '01',
          title: 'Fisión Nuclear y Reacción en Cadena',
          shortGoal: 'División de núcleos pesados, neutrones libres y control.',
          durationLabel: '6 min',
          coreConcept:
              'La fisión nuclear divide un núcleo atómico pesado e inestable (Uranio-235) al absorber un neutrón, liberando gran energía y nuevos neutrones capaces de fisionar otros núcleos.',
          formulaOrRule:
              '²³⁵U + ¹n → ¹⁴¹Ba + ⁹²Kr + 3 ¹n + Energía (ΔE = Δm · c²)',
          keySteps: [
            'Un neutrón impacta y desestabiliza un núcleo pesado de Uranio-235.',
            'El núcleo se divide en dos núcleos más ligeros liberando calor y neutrones.',
            'Las barras de control absorben neutrones excedentes para regular la reacción.',
          ],
          examplePrompt:
              '¿Qué función cumplen las barras de control en una central nuclear?',
          exampleResolution:
              'Absorben neutrones excedentes (con boro o cadmio) para mantener la reacción estable.',
          checkQuestion: '¿Qué ocurre en una fisión nuclear?',
          checkOptions: [
            'Dos núcleos ligeros se fusionan en uno pesado.',
            'Un núcleo pesado se divide al absorber un neutrón, liberando energía.',
            'Los electrones se convierten en protones.',
            'Un átomo se detiene por completo.',
          ],
          correctOptionIndex: 1,
          checkExplanation:
              'Fisión significa división de un núcleo pesado; la unión de núcleos ligeros es fusión.',
        ),
        KadirSyllabusTopic(
          id: 'ci-02',
          area: KadirAreaId.ciencias,
          unitNumber: '02',
          title: 'Leyes de Newton y fuerza neta',
          shortGoal: 'Inercia, segunda ley (F = m·a) y acción-reacción.',
          durationLabel: '6 min',
          coreConcept:
              'Un cuerpo mantiene su estado salvo que actúe una fuerza neta (inercia), la aceleración es proporcional a la fuerza neta (F = m·a) y toda acción tiene una reacción igual y opuesta.',
          formulaOrRule: 'F_neta = m · a   (1 N = 1 kg · m/s²)',
          keySteps: [
            '1ra Ley: si F_neta = 0 N, el objeto sigue en reposo o con velocidad constante.',
            '2da Ley: calcula aceleración con a = F / m.',
            '3ra Ley: acción y reacción actúan sobre cuerpos distintos en sentido opuesto.',
          ],
          examplePrompt:
              'Empujas una caja de 5 kg con una fuerza neta de 20 N. ¿Cuál es su aceleración?',
          exampleResolution: 'a = F / m = 20 N / 5 kg = 4 m/s².',
          checkQuestion:
              'Si aplicas 30 N de fuerza neta a un carrito de 6 kg, ¿qué aceleración adquiere?',
          checkOptions: ['3 m/s²', '5 m/s²', '18 m/s²', '36 m/s²'],
          correctOptionIndex: 1,
          checkExplanation: 'Por la segunda ley de Newton: a = 30 / 6 = 5 m/s².',
        ),
        KadirSyllabusTopic(
          id: 'ci-03',
          area: KadirAreaId.ciencias,
          unitNumber: '03',
          title: 'Fotosíntesis y respiración celular',
          shortGoal: 'Conversión de energía solar en glucosa y liberación de ATP.',
          durationLabel: '5 min',
          coreConcept:
              'En los cloroplastos la fotosíntesis convierte luz, agua y CO₂ en glucosa y O₂. En las mitocondrias la respiración celular descompone la glucosa con O₂ para liberar energía útil (ATP).',
          formulaOrRule: '6 CO₂ + 6 H₂O + Luz ⇄ C₆H₁₂O₆ + 6 O₂',
          keySteps: [
            'Fotosíntesis: ocurre en cloroplastos y almacena energía en glucosa.',
            'Respiración celular: ocurre en mitocondrias y produce ATP.',
            'Son procesos complementarios: los productos de uno son reactivos del otro.',
          ],
          examplePrompt:
              '¿En qué organelo celular se libera ATP a partir de glucosa y oxígeno?',
          exampleResolution: 'En la mitocondria, mediante respiración celular.',
          checkQuestion:
              '¿Qué gas liberan las plantas como producto principal de la fotosíntesis?',
          checkOptions: [
            'Dióxido de carbono (CO₂)',
            'Oxígeno (O₂)',
            'Nitrógeno (N₂)',
            'Metano (CH₄)',
          ],
          correctOptionIndex: 1,
          checkExplanation:
              'Las plantas absorben CO₂ y liberan oxígeno (O₂) durante la fotosíntesis.',
        ),
        KadirSyllabusTopic(
          id: 'ci-04',
          area: KadirAreaId.ciencias,
          unitNumber: '04',
          title: 'Enlaces químicos (iónico y covalente)',
          shortGoal: 'Transferencia y compartición de electrones de valencia.',
          durationLabel: '5 min',
          coreConcept:
              'Los átomos se enlazan buscando estabilidad (octeto). En el enlace iónico un metal transfiere electrones a un no metal; en el covalente dos no metales comparten pares de electrones.',
          formulaOrRule:
              'Iónico = Metal + No metal (transfiere e⁻)  |  Covalente = No metales (comparte e⁻)',
          keySteps: [
            'Observa los electrones de valencia de cada elemento.',
            'Metal + no metal forman iones opuestos que se atraen (iónico).',
            'Dos no metales comparten pares de electrones (covalente).',
          ],
          examplePrompt:
              '¿Qué tipo de enlace une al sodio (metal) y al cloro (no metal) en la sal?',
          exampleResolution:
              'Enlace iónico: el sodio cede 1 electrón al cloro formando Na⁺ y Cl⁻.',
          checkQuestion:
              '¿Qué sucede con los electrones en un enlace covalente como el agua (H₂O)?',
          checkOptions: [
            'Se destruyen en la reacción.',
            'Se comparten entre átomos no metálicos.',
            'Pasan del metal al aire.',
            'Se convierten en neutrones.',
          ],
          correctOptionIndex: 1,
          checkExplanation:
              'Hidrógeno y oxígeno son no metales, por lo que comparten electrones.',
        ),
      ];
  }
}

/// ============================================================================
/// 2. PANTALLA PRINCIPAL DE PRÁCTICA (Hub + Estudio Directo + Ruta 4 Fases)
/// ============================================================================

enum _PracticeStep { hub, directStudy, loading, route }

class KadirPracticeScreen extends StatefulWidget {
  final KadirAreaId area;
  final KadirPaletteMode paletteMode;
  final KadirMascotId mascotId;
  final String userAlias;
  final int streakDays;
  final String initialUniverse;
  final Set<String> initialCompletedTopicIds;

  /// Callback opcional para conectar tu endpoint real de IA (Gemini).
  /// Si es null, usa el generador estructurado local listo para probar.
  final Future<KadirAnalogyRoute> Function({
    required KadirAreaId area,
    required String topic,
    required String universe,
    required KadirStudyFocus focus,
  })? onGenerateAnalogyRoute;

  final ValueChanged<String>? onTopicCompleted;
  final ValueChanged<KadirAnalogyRoute>? onSaveAccordion;
  final VoidCallback? onBackToModes;
  final VoidCallback? onBackToHome;
  final VoidCallback? onOpenProgress;
  final VoidCallback? onOpenProfile;

  const KadirPracticeScreen({
    super.key,
    required this.area,
    this.paletteMode = KadirPaletteMode.aurora,
    this.mascotId = KadirMascotId.lumi,
    this.userAlias = 'Estudiante Kadir',
    this.streakDays = 3,
    this.initialUniverse = 'Minecraft',
    this.initialCompletedTopicIds = const {},
    this.onGenerateAnalogyRoute,
    this.onTopicCompleted,
    this.onSaveAccordion,
    this.onBackToModes,
    this.onBackToHome,
    this.onOpenProgress,
    this.onOpenProfile,
  });

  @override
  State<KadirPracticeScreen> createState() => _KadirPracticeScreenState();
}

class _KadirPracticeScreenState extends State<KadirPracticeScreen> {
  static const List<String> _presetUniverses = [
    'Minecraft',
    'Left 4 Dead',
    'Naruto',
    'Fútbol',
    'Brawl Stars',
    'Dragon Ball',
  ];

  late List<KadirSyllabusTopic> _topics;
  late String _selectedTopicId;
  late Set<String> _completedIds;
  late String _universe;
  KadirStudyFocus _focus = KadirStudyFocus.desdeCero;

  _PracticeStep _step = _PracticeStep.hub;
  int _mobileHubTab = 0; // 0 = Temario, 1 = Analogía IA
  bool _editingUniverse = false;

  late final TextEditingController _topicCtrl;
  late final TextEditingController _universeCtrl;

  // Estado de Estudio Directo
  final Map<String, int> _directAnswers = {};

  // Estado de Ruta de 4 Fases
  KadirAnalogyRoute? _activeRoute;
  int _routePhase = 1; // 1..4
  final Set<int> _flippedEqIndexes = {};
  int _storyCardIdx = 0;
  int? _routeQuizAnswer;
  bool _accordionSaved = false;

  @override
  void initState() {
    super.initState();
    _topics = getKadirSyllabus(widget.area);
    _selectedTopicId = _topics.first.id;
    _completedIds = Set<String>.from(widget.initialCompletedTopicIds);
    _universe = widget.initialUniverse;
    _topicCtrl = TextEditingController(text: _topics.first.title);
    _universeCtrl = TextEditingController(text: _universe);
  }

  @override
  void dispose() {
    _topicCtrl.dispose();
    _universeCtrl.dispose();
    super.dispose();
  }

  KadirSyllabusTopic get _selectedTopic => _topics.firstWhere(
        (t) => t.id == _selectedTopicId,
        orElse: () => _topics.first,
      );

  String get _areaName {
    switch (widget.area) {
      case KadirAreaId.logicoMatematico:
        return 'Lógico Matemático';
      case KadirAreaId.comprensionLectora:
        return 'Comprensión Lectora';
      case KadirAreaId.ciencias:
        return 'Ciencias';
    }
  }

  String get _mascotName {
    switch (widget.mascotId) {
      case KadirMascotId.kitsune:
        return 'Kitsune';
      case KadirMascotId.yaka:
        return 'Yaka';
      case KadirMascotId.lumi:
        return 'Lumi';
    }
  }

  String get _initials {
    final parts = widget.userAlias
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'EK';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  int get _completedInArea =>
      _topics.where((t) => _completedIds.contains(t.id)).length;

  void _selectTopic(KadirSyllabusTopic topic) {
    setState(() {
      _selectedTopicId = topic.id;
      _topicCtrl.text = topic.title;
    });
  }

  void _markTopicDone(String id) {
    if (!_completedIds.contains(id)) {
      setState(() => _completedIds.add(id));
      widget.onTopicCompleted?.call(id);
    }
  }

  Future<void> _launchAnalogyRoute() async {
    final cleanTopic = _topicCtrl.text.trim().isEmpty
        ? _selectedTopic.title
        : _topicCtrl.text.trim();

    setState(() {
      _step = _PracticeStep.loading;
      _accordionSaved = false;
    });

    try {
      final KadirAnalogyRoute route;
      if (widget.onGenerateAnalogyRoute != null) {
        route = await widget.onGenerateAnalogyRoute!(
          area: widget.area,
          topic: cleanTopic,
          universe: _universe,
          focus: _focus,
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 650));
        route = _buildLocalFallbackRoute(cleanTopic);
      }

      if (!mounted) return;
      setState(() {
        _activeRoute = route;
        _routePhase = 1;
        _flippedEqIndexes.clear();
        _storyCardIdx = 0;
        _routeQuizAnswer = null;
        _step = _PracticeStep.route;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _step = _PracticeStep.hub);
    }
  }

  KadirAnalogyRoute _buildLocalFallbackRoute(String topicTitle) {
    final t = _selectedTopic;
    return KadirAnalogyRoute(
      topic: topicTitle,
      universe: _universe,
      equivalences: [
        KadirAnalogyEquivalence(
          universeConcept: 'Núcleo base en $_universe',
          realConcept: t.title,
          shortDesc: t.shortGoal,
        ),
        KadirAnalogyEquivalence(
          universeConcept: 'Regla maestra de partida',
          realConcept: 'Fórmula / Regla clave',
          shortDesc: t.formulaOrRule,
        ),
        KadirAnalogyEquivalence(
          universeConcept: 'Combo ganador paso a paso',
          realConcept: 'Procedimiento formal',
          shortDesc: t.keySteps.first,
        ),
      ],
      storyCards: [
        'Imagina que entras a una misión en $_universe donde dominar "$topicTitle" decide la victoria. ${t.coreConcept}',
        'Tu herramienta principal funciona con esta regla exacta: ${t.formulaOrRule}.',
        'En acción: ${t.examplePrompt} → ${t.exampleResolution}',
      ],
      questionPrompt: t.checkQuestion,
      questionOptions: t.checkOptions,
      correctIndex: t.correctOptionIndex,
      questionFeedback: t.checkExplanation,
      formalDefinition: t.coreConcept,
      formulaOrRule: t.formulaOrRule,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = KadirPalette.fromMode(widget.paletteMode);

    return Scaffold(
      backgroundColor: palette.bgMain,
      body: Stack(
        children: [
          Positioned.fill(child: _PracticeBackdrop(palette: palette)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 860;
                final hPadding = isWide ? 32.0 : 16.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hPadding,
                        vertical: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. CABECERA SUPERIOR UNIFICADA
                          _buildTopHeader(context, palette),
                          const SizedBox(height: 14),

                          // 2. CONTENIDO SEGÚN PASO ACTIVO
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: _buildBodyForStep(palette, isWide),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyForStep(KadirPalette palette, bool isWide) {
    switch (_step) {
      case _PracticeStep.hub:
        return _buildHubView(palette, isWide);
      case _PracticeStep.directStudy:
        return _buildDirectStudyView(palette, isWide);
      case _PracticeStep.loading:
        return _buildLoadingView(palette);
      case _PracticeStep.route:
        return _buildRouteView(palette);
    }
  }

  /// CABECERA SUPERIOR (Volver al Inicio + Racha + Perfil)
  Widget _buildTopHeader(BuildContext context, KadirPalette palette) {
    final pillBg = palette.isDark
        ? _pAlpha(palette.surface, 0.78)
        : _pAlpha(Colors.white, 0.84);

    return Row(
      children: [
        Flexible(
          child: _PracticePillButton(
            onTap: widget.onBackToHome ?? () => Navigator.maybePop(context),
            bgColor: pillBg,
            borderColor: palette.glassBorder,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded, size: 16, color: palette.textMain),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Volver al Inicio',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: palette.textMain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PracticePillButton(
              onTap: widget.onOpenProgress,
              bgColor: pillBg,
              borderColor: palette.glassBorder,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      size: 16, color: palette.accent),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.streakDays} días',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: palette.textMain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _PracticePillButton(
              onTap: widget.onOpenProfile,
              bgColor: pillBg,
              borderColor: palette.glassBorder,
              borderRadius: 999,
              padding: EdgeInsets.zero,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Text(
                    _initials,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: palette.textMain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ==========================================================================
  /// VISTA 1: HUB (Temario de aprendizaje + Aprender por Analogía IA)
  /// ==========================================================================
  Widget _buildHubView(KadirPalette palette, bool isWide) {
    final pillBg = palette.isDark
        ? _pAlpha(palette.surface, 0.78)
        : _pAlpha(Colors.white, 0.84);

    return Column(
      key: const ValueKey('practice-hub'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-cabecera limpia del área (Sin "Práctica · Prisma")
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _areaName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isWide ? 26 : 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: palette.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_completedInArea/${_topics.length} dominados · Temario y Analogía IA',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _PracticePillButton(
              onTap: widget.onBackToModes ?? () => Navigator.maybePop(context),
              bgColor: pillBg,
              borderColor: palette.glassBorder,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 15, color: palette.textMain),
                  const SizedBox(width: 5),
                  Text(
                    'Áreas',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: palette.textMain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Selector móvil compacto (evita apilamiento infinito)
        if (!isWide) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.glassBorder),
            ),
            child: Row(
              children: [
                _buildSegmentTab(
                  palette: palette,
                  label: 'Temario',
                  active: _mobileHubTab == 0,
                  onTap: () => setState(() => _mobileHubTab = 0),
                ),
                const SizedBox(width: 4),
                _buildSegmentTab(
                  palette: palette,
                  label: 'Analogía IA',
                  active: _mobileHubTab == 1,
                  onTap: () => setState(() => _mobileHubTab = 1),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 14),

        // Cuerpo principal (2 columnas en tablet/PC, pestaña activa en móvil)
        Expanded(
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildSyllabusCard(palette),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 5,
                      child: _buildAnalogyStudioCard(palette),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _mobileHubTab == 0
                      ? _buildSyllabusCard(palette, shrinkWrap: true)
                      : _buildAnalogyStudioCard(palette, shrinkWrap: true),
                ),
        ),
      ],
    );
  }

  Widget _buildSegmentTab({
    required KadirPalette palette,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: active
                ? LinearGradient(colors: [palette.primary, palette.secondary])
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : palette.textMain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Panel izquierdo: Temario de aprendizaje
  Widget _buildSyllabusCard(KadirPalette palette, {bool shrinkWrap = false}) {
    final topicList = Column(
      mainAxisSize: MainAxisSize.min,
      children: _topics.map((topic) {
        final selected = topic.id == _selectedTopicId;
        final done = _completedIds.contains(topic.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _selectTopic(topic),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: selected
                      ? _pAlpha(palette.primary, palette.isDark ? 0.16 : 0.08)
                      : (palette.isDark
                          ? _pAlpha(palette.surface, 0.55)
                          : _pAlpha(Colors.white, 0.65)),
                  border: Border.all(
                    color: selected ? palette.primary : palette.glassBorder,
                    width: selected ? 1.6 : 1.1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? const Color(0xFF0D9488)
                            : (selected
                                ? palette.primary
                                : _pAlpha(palette.primary, 0.14)),
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check_rounded,
                                size: 17, color: Colors.white)
                            : Text(
                                topic.unitNumber,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: selected
                                      ? Colors.white
                                      : palette.primary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: palette.textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            topic.shortGoal,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      topic.durationLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: selected ? palette.primary : palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );

    final footerBar = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: palette.isDark
            ? _pAlpha(palette.surface, 0.65)
            : _pAlpha(Colors.white, 0.72),
        border: Border.all(color: palette.glassBorder),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Regla clave · Tema ${_selectedTopic.unitNumber}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: palette.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedTopic.formulaOrRule,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: palette.textMain,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => setState(() => _step = _PracticeStep.directStudy),
            icon: Icon(Icons.menu_book_rounded, size: 16, color: palette.primary),
            label: Text(
              'Estudiar contenido directo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: palette.textMain,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: palette.primary, width: 1.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            ),
          ),
        ],
      ),
    );

    return _PracticeGlassCard(
      palette: palette,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Row(
            children: [
              Icon(Icons.layers_rounded, size: 17, color: palette.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Temario de aprendizaje',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: palette.textMain,
                  ),
                ),
              ),
              Text(
                '$_completedInArea/${_topics.length} completados',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (shrinkWrap)
            topicList
          else
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: topicList,
              ),
            ),
          const SizedBox(height: 6),
          footerBar,
        ],
      ),
    );
  }

  /// Panel derecho: Aprender por Analogía IA
  Widget _buildAnalogyStudioCard(KadirPalette palette,
      {bool shrinkWrap = false}) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Encabezado
        Row(
          children: [
            Icon(Icons.bolt_rounded, size: 18, color: palette.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Aprender por Analogía IA',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: palette.textMain,
                ),
              ),
            ),
            Text(
              'Guía: $_mascotName',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: palette.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Convierte cualquier tema del temario en una historia interactiva de tu universo favorito.',
          style: TextStyle(
            fontSize: 11.5,
            height: 1.35,
            color: palette.textMuted,
          ),
        ),
        const SizedBox(height: 12),

        // Resumen compacto de las 4 fases
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: palette.isDark
                ? _pAlpha(palette.surface, 0.55)
                : _pAlpha(Colors.white, 0.65),
            border: Border.all(color: palette.glassBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ruta interactiva · 4 fases',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: palette.primary,
                      ),
                    ),
                  ),
                  Text(
                    _universe,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _phaseMiniTile(palette, '01', 'Puente', 'Equivalencias'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _phaseMiniTile(palette, '02', 'Historia', 'Micro-lección'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _phaseMiniTile(palette, '03', 'Reto', '3 niveles'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _phaseMiniTile(palette, '04', 'Examen', 'Regla formal'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Universo ancla
        Row(
          children: [
            Expanded(
              child: Text(
                'Universo ancla',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: palette.textMuted,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  setState(() => _editingUniverse = !_editingUniverse),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _editingUniverse ? 'Listo' : 'Cambiar universo',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: palette.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (_editingUniverse) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _presetUniverses.map((u) {
              final active = u.toLowerCase() == _universe.toLowerCase();
              return ChoiceChip(
                label: Text(u),
                selected: active,
                onSelected: (_) {
                  setState(() {
                    _universe = u;
                    _universeCtrl.text = u;
                    _editingUniverse = false;
                  });
                },
                selectedColor: palette.primary,
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : palette.textMain,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _universeCtrl,
            style: TextStyle(fontSize: 13, color: palette.textMain),
            decoration: InputDecoration(
              hintText: 'O escribe otro universo...',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                setState(() {
                  _universe = val.trim();
                  _editingUniverse = false;
                });
              }
            },
          ),
        ] else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: palette.isDark
                  ? _pAlpha(palette.surface, 0.72)
                  : _pAlpha(Colors.white, 0.78),
              border: Border.all(color: palette.glassBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.explore_outlined, size: 16, color: palette.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _universe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: palette.textMain,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        // Enfoque (3 opciones en Wrap para cero overflow)
        Text(
          'Enfoque',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: palette.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: KadirStudyFocus.values.map((f) {
            final active = _focus == f;
            return GestureDetector(
              onTap: () => setState(() => _focus = f),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: active
                      ? LinearGradient(
                          colors: [palette.primary, palette.secondary],
                        )
                      : null,
                  color: active
                      ? null
                      : (palette.isDark
                          ? _pAlpha(palette.surface, 0.72)
                          : _pAlpha(Colors.white, 0.80)),
                  border: Border.all(
                    color: active ? Colors.transparent : palette.glassBorder,
                  ),
                ),
                child: Text(
                  f.label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: active ? Colors.white : palette.textMain,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Tema a transformar
        Row(
          children: [
            Expanded(
              child: Text(
                'Tema a transformar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: palette.textMuted,
                ),
              ),
            ),
            Text(
              'Sincronizado al temario',
              style: TextStyle(fontSize: 10.5, color: palette.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _topicCtrl,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: palette.textMain,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: palette.isDark
                ? _pAlpha(palette.surface, 0.72)
                : _pAlpha(Colors.white, 0.85),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: palette.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: palette.glassBorder),
            ),
          ),
        ),
      ],
    );

    final ctaButton = SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [palette.primary, palette.secondary],
          ),
          boxShadow: [
            BoxShadow(
              color: _pAlpha(palette.primary, 0.28),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _launchAnalogyRoute,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt_rounded, size: 18, color: Color(0xFFF6C453)),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Generar Analogía con IA',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 17, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );

    return _PracticeGlassCard(
      palette: palette,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        children: [
          if (shrinkWrap)
            content
          else
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: content,
              ),
            ),
          const SizedBox(height: 14),
          ctaButton,
        ],
      ),
    );
  }

  Widget _phaseMiniTile(
    KadirPalette palette,
    String num,
    String title,
    String sub,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: palette.glassBorder),
      ),
      child: Row(
        children: [
          Text(
            num,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: palette.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: palette.textMain,
                  ),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: palette.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ==========================================================================
  /// VISTA 2: ESTUDIO DIRECTO DEL TEMA (Concepto + Regla + Ejemplo + Check)
  /// ==========================================================================
  Widget _buildDirectStudyView(KadirPalette palette, bool isWide) {
    final topic = _selectedTopic;
    final selectedAnswer = _directAnswers[topic.id];
    final isCorrect = selectedAnswer == topic.correctOptionIndex;

    return SingleChildScrollView(
      key: const ValueKey('direct-study'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra superior de estudio directo
          Row(
            children: [
              _PracticePillButton(
                onTap: () => setState(() => _step = _PracticeStep.hub),
                bgColor: palette.isDark
                    ? _pAlpha(palette.surface, 0.8)
                    : _pAlpha(Colors.white, 0.86),
                borderColor: palette.glassBorder,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_rounded,
                        size: 15, color: palette.textMain),
                    const SizedBox(width: 5),
                    Text(
                      'Temario',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: palette.textMain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  topic.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isWide ? 22 : 18,
                    fontWeight: FontWeight.w800,
                    color: palette.textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Concepto + Fórmula + Pasos
          _PracticeGlassCard(
            palette: palette,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Concepto clave',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: palette.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  topic.coreConcept,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: palette.textMain,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _pAlpha(palette.primary, palette.isDark ? 0.16 : 0.08),
                    border: Border.all(color: _pAlpha(palette.primary, 0.35)),
                  ),
                  child: Text(
                    topic.formulaOrRule,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: palette.textMain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...topic.keySteps.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${e.key + 1}. ',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: palette.primary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  color: palette.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Ejemplo resuelto + Comprobación rápida
          _PracticeGlassCard(
            palette: palette,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ejemplo resuelto',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: palette.secondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  topic.examplePrompt,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: palette.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  topic.exampleResolution,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: palette.textMuted,
                  ),
                ),
                const Divider(height: 24),
                Text(
                  'Comprobación rápida',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: palette.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  topic.checkQuestion,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: palette.textMain,
                  ),
                ),
                const SizedBox(height: 10),
                ...topic.checkOptions.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final chosen = selectedAnswer == idx;
                  final right = idx == topic.correctOptionIndex;
                  Color borderCol = palette.glassBorder;
                  if (selectedAnswer != null && right) {
                    borderCol = const Color(0xFF0D9488);
                  } else if (chosen && !right) {
                    borderCol = const Color(0xFFE11D48);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() => _directAnswers[topic.id] = idx);
                        if (right) _markTopicDone(topic.id);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderCol,
                            width: chosen || (selectedAnswer != null && right)
                                ? 1.8
                                : 1.1,
                          ),
                          color: palette.isDark
                              ? _pAlpha(palette.surface, 0.65)
                              : _pAlpha(Colors.white, 0.78),
                        ),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: palette.textMain,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                if (selectedAnswer != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _pAlpha(
                        isCorrect
                            ? const Color(0xFF0D9488)
                            : const Color(0xFFD97706),
                        0.14,
                      ),
                    ),
                    child: Text(
                      isCorrect
                          ? '¡Correcto! ${topic.checkExplanation}'
                          : 'Pista: ${topic.checkExplanation}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: palette.textMain,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _launchAnalogyRoute,
                      icon: const Icon(Icons.bolt_rounded, size: 16),
                      label: const Text('Ver en Analogía IA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _markTopicDone(topic.id);
                        setState(() => _step = _PracticeStep.hub);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: palette.glassBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Volver al temario',
                        style: TextStyle(color: palette.textMain),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ==========================================================================
  /// VISTA 3: CARGANDO ANALOGÍA
  /// ==========================================================================
  Widget _buildLoadingView(KadirPalette palette) {
    return Center(
      key: const ValueKey('loading-analogy'),
      child: _PracticeGlassCard(
        palette: palette,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: palette.primary, strokeWidth: 3),
            const SizedBox(height: 16),
            Text(
              'Construyendo tu ruta en $_universe...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: palette.textMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$_mascotName está conectando el tema con tu universo favorito.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  /// ==========================================================================
  /// VISTA 4: RUTA INTERACTIVA DE 4 FASES (Sin etiqueta Caché)
  /// ==========================================================================
  Widget _buildRouteView(KadirPalette palette) {
    final route = _activeRoute;
    if (route == null) return const SizedBox.shrink();

    final phases = const ['1. Puente', '2. Historia', '3. Reto', '4. Examen'];

    return Column(
      key: const ValueKey('analogy-route'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabecera + Stepper de 4 fases
        _PracticeGlassCard(
          palette: palette,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _PracticePillButton(
                    onTap: () => setState(() => _step = _PracticeStep.hub),
                    bgColor: palette.isDark
                        ? _pAlpha(palette.surface, 0.8)
                        : _pAlpha(Colors.white, 0.85),
                    borderColor: palette.glassBorder,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    child: Icon(Icons.arrow_back_rounded,
                        size: 16, color: palette.textMain),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${route.universe} · $_areaName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: palette.primary,
                          ),
                        ),
                        Text(
                          route.topic,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: palette.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(phases.length, (i) {
                  final phaseNum = i + 1;
                  final active = _routePhase == phaseNum;
                  final done = _routePhase > phaseNum;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _routePhase = phaseNum),
                      child: Container(
                        margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: active
                              ? LinearGradient(
                                  colors: [palette.primary, palette.secondary],
                                )
                              : null,
                          color: active
                              ? null
                              : (done
                                  ? _pAlpha(const Color(0xFF0D9488), 0.18)
                                  : Colors.transparent),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              phases[i],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: active ? Colors.white : palette.textMain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Contenido de la fase activa
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: _buildActivePhaseContent(palette, route),
          ),
        ),
      ],
    );
  }

  Widget _buildActivePhaseContent(
    KadirPalette palette,
    KadirAnalogyRoute route,
  ) {
    if (_routePhase == 1) {
      return _PracticeGlassCard(
        palette: palette,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Puente de equivalencias',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: palette.textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Toca cada tarjeta para descubrir su concepto real.',
              style: TextStyle(fontSize: 12, color: palette.textMuted),
            ),
            const SizedBox(height: 12),
            ...route.equivalences.asMap().entries.map((entry) {
              final flipped = _flippedEqIndexes.contains(entry.key);
              final eq = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    setState(() {
                      if (flipped) {
                        _flippedEqIndexes.remove(entry.key);
                      } else {
                        _flippedEqIndexes.add(entry.key);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: flipped ? palette.primary : palette.glassBorder,
                        width: flipped ? 1.6 : 1.1,
                      ),
                      color: flipped
                          ? _pAlpha(palette.primary, palette.isDark ? 0.16 : 0.08)
                          : (palette.isDark
                              ? _pAlpha(palette.surface, 0.65)
                              : _pAlpha(Colors.white, 0.78)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flipped ? 'Concepto real' : route.universe,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: palette.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          flipped ? eq.realConcept : eq.universeConcept,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: palette.textMain,
                          ),
                        ),
                        if (flipped) ...[
                          const SizedBox(height: 4),
                          Text(
                            eq.shortDesc,
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => setState(() => _routePhase = 2),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Continuar a Historia →'),
            ),
          ],
        ),
      );
    }

    if (_routePhase == 2) {
      final total = route.storyCards.length;
      return _PracticeGlassCard(
        palette: palette,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tarjeta ${_storyCardIdx + 1} de $total',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: palette.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              route.storyCards[_storyCardIdx],
              style: TextStyle(
                fontSize: 14.5,
                height: 1.5,
                color: palette.textMain,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                if (_storyCardIdx > 0)
                  OutlinedButton(
                    onPressed: () => setState(() => _storyCardIdx--),
                    child: const Text('Anterior'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (_storyCardIdx < total - 1) {
                      setState(() => _storyCardIdx++);
                    } else {
                      setState(() => _routePhase = 3);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _storyCardIdx < total - 1
                        ? 'Siguiente tarjeta'
                        : 'Ir al Reto →',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_routePhase == 3) {
      final answered = _routeQuizAnswer != null;
      return _PracticeGlassCard(
        palette: palette,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Reto de dominio',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: palette.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              route.questionPrompt,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: palette.textMain,
              ),
            ),
            const SizedBox(height: 12),
            ...route.questionOptions.asMap().entries.map((entry) {
              final idx = entry.key;
              final right = idx == route.correctIndex;
              final chosen = _routeQuizAnswer == idx;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _routeQuizAnswer = idx),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: answered && right
                            ? const Color(0xFF0D9488)
                            : (chosen
                                ? const Color(0xFFE11D48)
                                : palette.glassBorder),
                        width: chosen || (answered && right) ? 1.8 : 1.1,
                      ),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: palette.textMain,
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (answered) ...[
              const SizedBox(height: 6),
              Text(
                route.questionFeedback,
                style: TextStyle(fontSize: 12.5, color: palette.textMuted),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => setState(() => _routePhase = 4),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ver Aterrizaje Formal →'),
              ),
            ],
          ],
        ),
      );
    }

    // Fase 4: Aterrizaje formal + Guardar acordeón
    return _PracticeGlassCard(
      palette: palette,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Aterrizaje real para tu examen',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: palette.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            route.formalDefinition,
            style: TextStyle(fontSize: 13.5, height: 1.45, color: palette.textMain),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _pAlpha(palette.primary, 0.10),
              border: Border.all(color: _pAlpha(palette.primary, 0.35)),
            ),
            child: Text(
              route.formulaOrRule,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: palette.textMain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _accordionSaved
                    ? null
                    : () {
                        setState(() => _accordionSaved = true);
                        widget.onSaveAccordion?.call(route);
                      },
                icon: Icon(
                  _accordionSaved
                      ? Icons.bookmark_added_rounded
                      : Icons.bookmark_add_outlined,
                  size: 16,
                ),
                label: Text(
                  _accordionSaved ? 'Acordeón guardado' : 'Guardar acordeón',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _markTopicDone(_selectedTopic.id);
                  setState(() => _step = _PracticeStep.hub);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Finalizar y marcar dominado'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// 3. TARJETA CRISTALINA, PILL Y FONDO COMPARTIDOS
/// ============================================================================

class _PracticeGlassCard extends StatelessWidget {
  final KadirPalette palette;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _PracticeGlassCard({
    required this.palette,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette.cardGlassGradient,
            ),
            border: Border.all(color: palette.glassBorder, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: _pAlpha(
                  palette.isDark ? Colors.black : palette.primary,
                  palette.isDark ? 0.34 : 0.09,
                ),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PracticePillButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color bgColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _PracticePillButton({
    required this.onTap,
    required this.bgColor,
    required this.borderColor,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PracticeBackdrop extends StatelessWidget {
  final KadirPalette palette;

  const _PracticeBackdrop({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -90,
          left: -70,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _pAlpha(palette.primary, palette.isDark ? 0.22 : 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -60,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _pAlpha(palette.secondary, palette.isDark ? 0.20 : 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}