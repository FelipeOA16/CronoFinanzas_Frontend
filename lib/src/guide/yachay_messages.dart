class YachayMessages {
  static const title = 'Yachay';

  static const home = [
    'Hoy es un buen dia para observar tu dinero antes de decidir.',
    'Un momento de calma puede ayudarte a elegir mejor tu siguiente paso.',
    'Tu camino financiero se cultiva con pequenas decisiones constantes.',
  ];

  static const deudas = [
    'Tus compromisos no son enemigos; son senales para organizar mejor tu camino.',
    'Observa primero tus compromisos importantes antes de asumir nuevos gastos.',
    'Vas ligero de compromisos. Es un buen momento para fortalecer tus metas.',
  ];

  static const metas = [
    'Una meta sin fecha es un sueno. Ponle plazo y empieza a cultivarla.',
    'Cada aporte es una semilla para el futuro que estas construyendo.',
    'Tu primera meta puede ser pequena. Lo importante es darle direccion a tu dinero.',
  ];

  static const cuentas = [
    'Tus cuentas son el mapa de tu dinero. Mantenerlas claras te da tranquilidad.',
    'Empieza creando tu primera cuenta para ver tu camino financiero.',
  ];

  static const presupuestos = [
    'Un presupuesto no limita tu vida; te ayuda a elegir mejor.',
    'Podrias revisar tu presupuesto antes de hacer un gasto nuevo.',
  ];

  static const emptyStates = [
    'Cada paso cuenta. Empieza con una accion pequena y clara.',
    'Este puede ser un buen momento para ordenar tu punto de partida.',
  ];

  static const success = [
    'Has cultivado una victoria. Celebra este avance.',
    'Cada avance confirma que tu constancia esta dando frutos.',
  ];

  static String homeDaily(int day) => home[day % home.length];
}
