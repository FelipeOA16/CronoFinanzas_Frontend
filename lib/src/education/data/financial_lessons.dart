import '../domain/entities/financial_lesson.dart';

class FinancialLessons {
  static const categories = [
    'Ahorro',
    'Presupuesto',
    'Deudas',
    'Metas',
    'Patrimonio',
    'Habitos financieros',
  ];

  static const lessons = [
    FinancialLesson(
      id: 'presupuesto-basico',
      category: 'Presupuesto',
      title: 'Que es un presupuesto?',
      shortDescription:
          'Una forma sencilla de decidir con anticipacion como usar tu dinero.',
      content: [
        'Un presupuesto compara el dinero que esperas recibir con los gastos que planeas realizar durante un periodo.',
        'No busca impedirte gastar. Te ayuda a reservar primero lo importante y a reconocer cuanto margen tienes para otras decisiones.',
        'Empieza con tres datos: ingresos estimados, gastos necesarios y una cantidad posible para ahorro o metas.',
      ],
      estimatedMinutes: 3,
      level: 'basico',
      yachayMessage:
          'Un presupuesto no limita tu vida; te ayuda a elegir mejor.',
      suggestedAction:
          'Anota tus ingresos y tres gastos necesarios del mes actual.',
    ),
    FinancialLesson(
      id: 'ingreso-vs-prestamo',
      category: 'Deudas',
      title: 'Ingreso y dinero prestado no son lo mismo',
      shortDescription:
          'Reconoce que un prestamo aumenta tu efectivo, pero tambien tus compromisos.',
      content: [
        'Un ingreso aumenta tu dinero sin crear una obligacion de devolverlo. Un prestamo entrega liquidez ahora, pero genera un compromiso futuro.',
        'Mirar solo el saldo de la cuenta puede dar una sensacion incompleta. Conviene observar tambien cuanto de ese dinero tiene una deuda asociada.',
        'Separar ambas ideas permite medir con mayor claridad tu capacidad real de gasto y tu patrimonio neto.',
      ],
      estimatedMinutes: 4,
      level: 'basico',
      yachayMessage:
          'El dinero que llega puede tener caminos distintos. Observar su origen aclara tus decisiones.',
      suggestedAction:
          'Revisa tus ingresos recientes e identifica si alguno corresponde a dinero prestado.',
    ),
    FinancialLesson(
      id: 'priorizar-deudas',
      category: 'Deudas',
      title: 'Como priorizar deudas',
      shortDescription:
          'Ordena compromisos por urgencia, costo e impacto cotidiano.',
      content: [
        'Priorizar no siempre significa pagar primero la deuda mas grande. La fecha proxima, el costo y las consecuencias de retrasarse tambien importan.',
        'Una lista clara permite distinguir compromisos criticos de aquellos que ofrecen mayor flexibilidad.',
        'Mientras organizas pagos, evita asumir nuevas obligaciones que reduzcan el margen necesario para las prioritarias.',
      ],
      estimatedMinutes: 5,
      level: 'intermedio',
      yachayMessage:
          'Tus compromisos son senales para organizar mejor tu camino.',
      suggestedAction:
          'Ordena tus deudas por fecha proxima y marca las dos mas importantes.',
    ),
    FinancialLesson(
      id: 'meta-con-fecha',
      category: 'Metas',
      title: 'Por que una meta necesita fecha',
      shortDescription:
          'Una fecha convierte un deseo general en un objetivo que puedes planificar.',
      content: [
        'La fecha objetivo ayuda a dividir una cantidad grande en aportes pequenos y comprensibles.',
        'No tiene que ser perfecta. Puede ajustarse cuando cambian tus ingresos o prioridades.',
        'Lo importante es que permita comparar el avance actual con el tiempo disponible.',
      ],
      estimatedMinutes: 3,
      level: 'basico',
      yachayMessage:
          'Una meta con direccion transforma pequenos aportes en avance visible.',
      suggestedAction:
          'Elige una meta y define una fecha realista para revisarla.',
    ),
    FinancialLesson(
      id: 'patrimonio-neto',
      category: 'Patrimonio',
      title: 'Que significa patrimonio neto',
      shortDescription:
          'Una mirada conjunta a lo que tienes, lo que debes y lo que te deben.',
      content: [
        'El patrimonio en cuentas muestra el dinero registrado en tus cuentas activas.',
        'El patrimonio neto estimado agrega una mirada mas amplia: considera lo que debes y lo que otras personas te deben.',
        'No es lo mismo que dinero disponible para gastar. Es una referencia sobre tu posicion financiera general.',
      ],
      estimatedMinutes: 4,
      level: 'intermedio',
      yachayMessage:
          'Mirar el conjunto ofrece una perspectiva mas tranquila que observar un solo saldo.',
      suggestedAction:
          'Compara tu patrimonio en cuentas con tu neto estimado y observa la diferencia.',
    ),
    FinancialLesson(
      id: 'gastos-impulsivos',
      category: 'Habitos financieros',
      title: 'Como evitar gastos impulsivos',
      shortDescription:
          'Crea una pausa breve entre el deseo de comprar y la decision.',
      content: [
        'Un gasto impulsivo suele responder a una emocion o a una oferta momentanea, no a una necesidad planificada.',
        'Una pausa de unas horas puede ayudarte a preguntar si la compra cabe en tu presupuesto y si compite con alguna meta.',
        'No se trata de eliminar todo gusto, sino de elegirlo de forma consciente.',
      ],
      estimatedMinutes: 3,
      level: 'basico',
      yachayMessage:
          'Una pausa pequena puede abrir espacio para una decision mas clara.',
      suggestedAction:
          'Revisa tus ultimos 3 gastos y preguntate si te acercan a tus metas.',
    ),
    FinancialLesson(
      id: 'fondo-emergencia',
      category: 'Ahorro',
      title: 'El fondo de emergencia',
      shortDescription:
          'Construye una reserva para afrontar imprevistos sin desordenar todo tu plan.',
      content: [
        'Un fondo de emergencia es dinero reservado para situaciones necesarias e inesperadas.',
        'No necesita comenzar con una cifra grande. Una primera meta pequena ya reduce la dependencia de deuda ante un imprevisto.',
        'Conviene mantenerlo identificado y evitar usarlo para gastos cotidianos planificables.',
      ],
      estimatedMinutes: 4,
      level: 'basico',
      yachayMessage:
          'Una reserva pequena tambien puede darte espacio para respirar.',
      suggestedAction:
          'Define un primer objetivo alcanzable para tu fondo de emergencia.',
    ),
    FinancialLesson(
      id: 'habitos-estabilidad',
      category: 'Habitos financieros',
      title: 'Pequenos habitos que construyen estabilidad',
      shortDescription:
          'La constancia cotidiana suele pesar mas que una decision aislada.',
      content: [
        'Registrar movimientos, revisar cuentas y observar el presupuesto son acciones breves que mantienen tu informacion confiable.',
        'Una revision semanal permite detectar gastos repetidos o compromisos proximos antes de que se conviertan en urgencias.',
        'El habito funciona mejor cuando es pequeno, concreto y ocurre en un momento definido.',
      ],
      estimatedMinutes: 4,
      level: 'basico',
      yachayMessage:
          'La estabilidad se cultiva con pasos pequenos que puedes repetir.',
      suggestedAction:
          'Reserva diez minutos esta semana para revisar cuentas, gastos y compromisos.',
    ),
  ];

  static FinancialLesson get featured => lessons.first;
}
