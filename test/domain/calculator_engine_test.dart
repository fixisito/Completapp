import 'package:flutter_test/flutter_test.dart';
import 'package:completapp/domain/calculator/calculator_domain.dart';

void main() {
  group('CalculatorEngine', () {
    final recetas = [
      const Receta(
        nombre: 'Italiano',
        emoji: '🇮🇹',
        ingredientes: ['Pan', 'Vienesa', 'Palta'],
      ),
      const Receta(nombre: 'Custom', emoji: '✏️', ingredientes: []),
    ];

    test('builds required ingredients from mixed diners', () {
      final comensales = [
        Comensal(id: 1, cantidadCompletos: 2, recetaIndex: 0),
        Comensal(
          id: 2,
          cantidadCompletos: 1,
          recetaIndex: 1,
          ingredientesCustom: ['Pan', 'Tomate'],
        ),
      ];

      final reqs = CalculatorEngine.ingredientesRequeridos(comensales, recetas);
      expect(reqs['Pan'], 3);
      expect(reqs['Vienesa'], 2);
      expect(reqs['Palta'], 2);
      expect(reqs['Tomate'], 1);
    });

    test('calculates total cost based on selected package size', () {
      final ingredientes = [
        Ingrediente(
          nombre: 'Pan',
          emoji: '🍞',
          formatos: [
            FormatoCompra('Pack 5', 5, 1000),
            FormatoCompra('Pack 10', 10, 1800),
          ],
        ),
      ];

      ingredientes.first.autoSeleccionarFormato(7);
      final reqs = {'Pan': 7};

      final total = CalculatorEngine.costoTotal(ingredientes, reqs);
      expect(total, 1800);
      expect(ingredientes.first.unidadesNecesarias(7), 1);
    });
  });
}
