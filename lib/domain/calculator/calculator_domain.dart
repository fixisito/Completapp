class FormatoCompra {
  final String nombre;
  final int rendimiento;
  final bool esUnidad;
  final int? pesoGramos;
  final int precioBase;
  int precioActual;

  FormatoCompra(
    this.nombre,
    this.rendimiento,
    this.precioBase, {
    this.esUnidad = false,
    this.pesoGramos,
  }) : precioActual = precioBase;
}

class Ingrediente {
  final String nombre;
  final String emoji;
  final List<FormatoCompra> formatos;
  int formatoSeleccionadoIndex;
  bool formatoBloqueadoPorUsuario;

  Ingrediente({
    required this.nombre,
    required this.emoji,
    required this.formatos,
    this.formatoSeleccionadoIndex = 0,
    this.formatoBloqueadoPorUsuario = false,
  });

  FormatoCompra get formatoActual => formatos[formatoSeleccionadoIndex];
  int get rendimientoActual => formatoActual.rendimiento;
  String get unidadCompra => formatoActual.nombre;
  int get precioActual => formatoActual.precioActual;

  int unidadesNecesarias(int requeridos) =>
      (requeridos == 0 || rendimientoActual == 0)
          ? 0
          : (requeridos / rendimientoActual).ceil();

  int costoPara(int requeridos) => unidadesNecesarias(requeridos) * precioActual;

  void autoSeleccionarFormato(int requeridos) {
    if (formatoBloqueadoPorUsuario || requeridos <= 0) return;
    var bestIndex = -1;
    for (var i = 0; i < formatos.length; i++) {
      if (formatos[i].rendimiento >= requeridos) {
        bestIndex = i;
        break;
      }
    }
    if (bestIndex == -1) {
      bestIndex = formatos.length - 1;
    }
    formatoSeleccionadoIndex = bestIndex;
  }
}

class Receta {
  final String nombre;
  final String emoji;
  final List<String> ingredientes;
  const Receta({
    required this.nombre,
    required this.emoji,
    required this.ingredientes,
  });
}

class Comensal {
  int id;
  int cantidadCompletos;
  int recetaIndex;
  List<String> ingredientesCustom;

  Comensal({
    required this.id,
    this.cantidadCompletos = 1,
    this.recetaIndex = 0,
    List<String>? ingredientesCustom,
  }) : ingredientesCustom = ingredientesCustom ?? [];
}

class CalculatorEngine {
  static Map<String, int> ingredientesRequeridos(
    List<Comensal> comensales,
    List<Receta> recetas,
  ) {
    final reqs = <String, int>{};
    for (final c in comensales) {
      if (c.cantidadCompletos == 0) continue;
      final ings = c.recetaIndex < recetas.length - 1
          ? recetas[c.recetaIndex].ingredientes
          : c.ingredientesCustom;
      for (final ing in ings) {
        reqs[ing] = (reqs[ing] ?? 0) + c.cantidadCompletos;
      }
    }
    return reqs;
  }

  static int costoTotal(
    List<Ingrediente> ingredientes,
    Map<String, int> requeridos,
  ) {
    var total = 0;
    for (final ing in ingredientes) {
      final cantidad = requeridos[ing.nombre] ?? 0;
      if (cantidad > 0) {
        total += ing.costoPara(cantidad);
      }
    }
    return total;
  }
}
