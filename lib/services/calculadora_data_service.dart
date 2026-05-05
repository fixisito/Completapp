import 'package:shared_preferences/shared_preferences.dart';
import 'prefs_utils.dart';

class CalculadoraDataService {
  static const keyPrecioIngredienteV3 = 'precio_v3_';
  static const keyFormatoBloqueado = 'formato_bloqueado_v3_';
  static const keyUltimosCompletos = 'ultimos_completos';

  static Future<Map<String, Map<String, int>>> cargarDatosIngredientes() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsKeys = prefs.getKeys();
    final datos = <String, Map<String, int>>{};
    for (final key in prefsKeys) {
      if (!key.startsWith(keyPrecioIngredienteV3)) continue;
      final rest = key.substring(keyPrecioIngredienteV3.length);
      final parts = rest.split('|');
      if (parts.length != 2) continue;
      final nombreIngrediente = parts[0];
      final nombreFormato = parts[1];
      final precio = prefs.getInt(key);
      if (precio == null) continue;
      datos.putIfAbsent(nombreIngrediente, () => {});
      datos[nombreIngrediente]![nombreFormato] = precio;
    }
    return datos;
  }

  static Future<void> guardarDatosIngrediente(
    String ingrediente,
    String formato,
    int precio,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$keyPrecioIngredienteV3$ingrediente|$formato', precio);
    } catch (error, stackTrace) {
      PrefsUtils.logError(
        'CalculadoraDataService.guardarDatosIngrediente',
        error,
        stackTrace,
      );
    }
  }

  static Future<Map<String, String>> cargarFormatosBloqueados() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsKeys = prefs.getKeys();
    final datos = <String, String>{};
    for (final key in prefsKeys) {
      if (key.startsWith(keyFormatoBloqueado)) {
        final nombreIngrediente = key.substring(keyFormatoBloqueado.length);
        final formato = prefs.getString(key);
        if (formato != null) datos[nombreIngrediente] = formato;
      }
    }
    return datos;
  }

  static Future<void> guardarFormatoBloqueado(
    String ingrediente,
    String formato,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$keyFormatoBloqueado$ingrediente', formato);
  }

  static Future<void> resetearFormatoBloqueado(String ingrediente) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$keyFormatoBloqueado$ingrediente');
  }

  static Future<int> cargarUltimosCompletos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(keyUltimosCompletos) ?? 0;
    } catch (error, stackTrace) {
      PrefsUtils.logError(
        'CalculadoraDataService.cargarUltimosCompletos',
        error,
        stackTrace,
      );
      return 0;
    }
  }

  static Future<void> guardarUltimosCompletos(int total) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(keyUltimosCompletos, total);
    } catch (error, stackTrace) {
      PrefsUtils.logError(
        'CalculadoraDataService.guardarUltimosCompletos',
        error,
        stackTrace,
      );
    }
  }
}
