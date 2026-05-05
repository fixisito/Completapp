import 'package:shared_preferences/shared_preferences.dart';
import 'prefs_utils.dart';

class JuegoDataService {
  static const keyMejorPuntaje = 'mejor_puntaje_atrapa';

  static Future<int> cargarMejorPuntaje() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(keyMejorPuntaje) ?? 0;
    } catch (error, stackTrace) {
      PrefsUtils.logError(
        'JuegoDataService.cargarMejorPuntaje',
        error,
        stackTrace,
      );
      return 0;
    }
  }

  static Future<void> guardarMejorPuntaje(int puntaje) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(keyMejorPuntaje, puntaje);
    } catch (error, stackTrace) {
      PrefsUtils.logError(
        'JuegoDataService.guardarMejorPuntaje',
        error,
        stackTrace,
      );
    }
  }
}
