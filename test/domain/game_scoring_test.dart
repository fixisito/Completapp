import 'package:flutter_test/flutter_test.dart';
import 'package:completapp/domain/juegos/game_scoring.dart';

void main() {
  group('GameScoring', () {
    test('awards points and coins for golden item', () {
      final result = GameScoring.onTouch(
        tipo: TipoItemJuego.dorado,
        puntajeActual: 5,
        monedasGanadasActuales: 2,
        vidasActuales: 3,
      );

      expect(result.puntaje, 8);
      expect(result.monedasGanadas, 7);
      expect(result.vidas, 3);
      expect(result.gameOver, isFalse);
      expect(result.touchedGoodItem, isTrue);
    });

    test('decrements life and sets game over on onion', () {
      final result = GameScoring.onTouch(
        tipo: TipoItemJuego.cebolla,
        puntajeActual: 3,
        monedasGanadasActuales: 1,
        vidasActuales: 1,
      );

      expect(result.vidas, 0);
      expect(result.gameOver, isTrue);
      expect(result.touchedGoodItem, isFalse);
    });
  });
}
