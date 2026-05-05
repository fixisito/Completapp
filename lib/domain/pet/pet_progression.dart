class ComidaEfecto {
  final int costo;
  final double comida;
  final double felicidad;
  final int exp;

  const ComidaEfecto({
    required this.costo,
    required this.comida,
    required this.felicidad,
    required this.exp,
  });
}

class PetProgressionResult {
  final double comida;
  final double felicidad;
  final int exp;
  final int nivel;
  final int monedas;
  final bool levelUp;

  const PetProgressionResult({
    required this.comida,
    required this.felicidad,
    required this.exp,
    required this.nivel,
    required this.monedas,
    required this.levelUp,
  });
}

class PetProgression {
  static PetProgressionResult applyFeed({
    required double comidaActual,
    required double felicidadActual,
    required int expActual,
    required int nivelActual,
    required int monedasActuales,
    required ComidaEfecto efecto,
  }) {
    var comida = (comidaActual + efecto.comida).clamp(0, 100).toDouble();
    var felicidad =
        (felicidadActual + efecto.felicidad).clamp(0, 100).toDouble();
    var exp = expActual + efecto.exp;
    var nivel = nivelActual;
    var monedas = monedasActuales - efecto.costo;

    final levelResult = _tryLevelUp(exp: exp, nivel: nivel);
    exp = levelResult.$1;
    nivel = levelResult.$2;

    return PetProgressionResult(
      comida: comida,
      felicidad: felicidad,
      exp: exp,
      nivel: nivel,
      monedas: monedas,
      levelUp: levelResult.$3,
    );
  }

  static PetProgressionResult applyPlay({
    required double comidaActual,
    required double felicidadActual,
    required int expActual,
    required int nivelActual,
    required int monedasActuales,
  }) {
    var comida = (comidaActual - 5).clamp(0, 100).toDouble();
    var felicidad = (felicidadActual + 15).clamp(0, 100).toDouble();
    var exp = expActual + 5;
    var nivel = nivelActual;

    final levelResult = _tryLevelUp(exp: exp, nivel: nivel);
    exp = levelResult.$1;
    nivel = levelResult.$2;

    return PetProgressionResult(
      comida: comida,
      felicidad: felicidad,
      exp: exp,
      nivel: nivel,
      monedas: monedasActuales,
      levelUp: levelResult.$3,
    );
  }

  static (int, int, bool) _tryLevelUp({
    required int exp,
    required int nivel,
  }) {
    final expNecesaria = nivel * 50;
    if (exp >= expNecesaria) {
      return (exp - expNecesaria, nivel + 1, true);
    }
    return (exp, nivel, false);
  }
}
