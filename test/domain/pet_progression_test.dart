import 'package:flutter_test/flutter_test.dart';
import 'package:completapp/domain/pet/pet_progression.dart';

void main() {
  group('PetProgression', () {
    test('applyFeed clamps values and levels up', () {
      const efecto = ComidaEfecto(
        costo: 10,
        comida: 30,
        felicidad: 20,
        exp: 15,
      );

      final result = PetProgression.applyFeed(
        comidaActual: 85,
        felicidadActual: 90,
        expActual: 45,
        nivelActual: 1,
        monedasActuales: 50,
        efecto: efecto,
      );

      expect(result.comida, 100);
      expect(result.felicidad, 100);
      expect(result.nivel, 2);
      expect(result.exp, 10);
      expect(result.monedas, 40);
      expect(result.levelUp, isTrue);
    });

    test('applyPlay increases happiness and decreases food', () {
      final result = PetProgression.applyPlay(
        comidaActual: 10,
        felicidadActual: 92,
        expActual: 10,
        nivelActual: 2,
        monedasActuales: 5,
      );

      expect(result.comida, 5);
      expect(result.felicidad, 100);
      expect(result.exp, 15);
      expect(result.nivel, 2);
      expect(result.monedas, 5);
      expect(result.levelUp, isFalse);
    });
  });
}
