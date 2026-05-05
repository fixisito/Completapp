enum TipoItemJuego { completo, dorado, cebolla }

class GameScoreResult {
  final int puntaje;
  final int monedasGanadas;
  final int vidas;
  final bool gameOver;
  final bool touchedGoodItem;

  const GameScoreResult({
    required this.puntaje,
    required this.monedasGanadas,
    required this.vidas,
    required this.gameOver,
    required this.touchedGoodItem,
  });
}

class GameScoring {
  static int spawnIntervalMs(int puntaje) {
    if (puntaje > 30) return 700;
    if (puntaje > 20) return 850;
    if (puntaje > 10) return 1000;
    return 1200;
  }

  static GameScoreResult onTouch({
    required TipoItemJuego tipo,
    required int puntajeActual,
    required int monedasGanadasActuales,
    required int vidasActuales,
  }) {
    var puntaje = puntajeActual;
    var monedas = monedasGanadasActuales;
    var vidas = vidasActuales;
    var touchedGood = false;

    switch (tipo) {
      case TipoItemJuego.completo:
        puntaje += 1;
        monedas += 1;
        touchedGood = true;
        break;
      case TipoItemJuego.dorado:
        puntaje += 3;
        monedas += 5;
        touchedGood = true;
        break;
      case TipoItemJuego.cebolla:
        vidas -= 1;
        break;
    }

    return GameScoreResult(
      puntaje: puntaje,
      monedasGanadas: monedas,
      vidas: vidas,
      gameOver: vidas <= 0,
      touchedGoodItem: touchedGood,
    );
  }
}
