import 'package:shared_preferences/shared_preferences.dart';
import 'prefs_utils.dart';

class PetDataService {
  static const keyMonedas = 'monedas';
  static const keyNombrePet = 'pet_nombre';
  static const keyComida = 'pet_hambre';
  static const keyFelicidad = 'pet_felicidad';
  static const keyNivel = 'pet_nivel';
  static const keyExp = 'pet_exp';
  static const keyAccesorio = 'pet_accesorio';
  static const keyTimestamp = 'pet_timestamp';
  static const keyMejorPuntaje = 'mejor_puntaje_atrapa';
  static const keyVecesAlimentado = 'stats_veces_alimentado';
  static const keyPartidasJugadas = 'stats_partidas_jugadas';
  static const keyFechaCreacion = 'stats_fecha_creacion';
  static const keyUltimaVisita = 'stats_ultima_visita';
  static const keyRachaDias = 'stats_racha_dias';
  static const keyAccesoriosDesbloqueados = 'accesorios_desbloqueados';

  static Future<int> getMonedas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyMonedas) ?? 0;
  }

  static Future<void> agregarMonedas(int cantidad) async {
    final prefs = await SharedPreferences.getInstance();
    final actual = prefs.getInt(keyMonedas) ?? 0;
    await prefs.setInt(keyMonedas, actual + cantidad);
  }

  static Future<bool> gastarMonedas(int cantidad) async {
    final prefs = await SharedPreferences.getInstance();
    final actual = prefs.getInt(keyMonedas) ?? 0;
    if (actual < cantidad) return false;
    await prefs.setInt(keyMonedas, actual - cantidad);
    return true;
  }

  static Future<String> getNombrePet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyNombrePet) ?? '';
  }

  static Future<void> setNombrePet(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyNombrePet, nombre);
  }

  static Future<Map<String, dynamic>> getPetStats() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimaVez = prefs.getInt(keyTimestamp) ?? 0;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final segundosPasados = ((ahora - ultimaVez) / 1000).floor();

    final comida = (prefs.getDouble(keyComida) ?? 80) - (segundosPasados ~/ 30) * 3;
    final felicidad =
        (prefs.getDouble(keyFelicidad) ?? 80) - (segundosPasados ~/ 30) * 2;

    return {
      'comida': comida.clamp(0.0, 100.0),
      'felicidad': felicidad.clamp(0.0, 100.0),
      'nivel': prefs.getInt(keyNivel) ?? 1,
      'exp': prefs.getInt(keyExp) ?? 0,
      'accesorio': prefs.getString(keyAccesorio) ?? '',
      'monedas': prefs.getInt(keyMonedas) ?? 0,
      'nombre': prefs.getString(keyNombrePet) ?? '',
    };
  }

  static Future<void> registrarAlimentacion() async {
    final prefs = await SharedPreferences.getInstance();
    final veces = prefs.getInt(keyVecesAlimentado) ?? 0;
    await prefs.setInt(keyVecesAlimentado, veces + 1);
  }

  static Future<void> registrarPartida() async {
    final prefs = await SharedPreferences.getInstance();
    final partidas = prefs.getInt(keyPartidasJugadas) ?? 0;
    await prefs.setInt(keyPartidasJugadas, partidas + 1);
  }

  static Future<void> verificarRachaDiaria() async {
    final prefs = await SharedPreferences.getInstance();
    final ahora = DateTime.now();
    final hoyStr = '${ahora.year}-${ahora.month}-${ahora.day}';
    final ultimaVisita = prefs.getString(keyUltimaVisita) ?? '';

    if (ultimaVisita == hoyStr) return;

    if (prefs.getString(keyFechaCreacion) == null) {
      await prefs.setString(keyFechaCreacion, hoyStr);
    }

    final ayer = ahora.subtract(const Duration(days: 1));
    final ayerStr = '${ayer.year}-${ayer.month}-${ayer.day}';

    var racha = prefs.getInt(keyRachaDias) ?? 0;
    if (ultimaVisita == ayerStr) {
      racha++;
    } else {
      racha = 1;
    }

    await prefs.setString(keyUltimaVisita, hoyStr);
    await prefs.setInt(keyRachaDias, racha);
  }

  static Future<Map<String, dynamic>> getEstadisticas() async {
    final prefs = await SharedPreferences.getInstance();
    final fechaCreacion = prefs.getString(keyFechaCreacion);
    var diasDesdeCreacion = 0;
    if (fechaCreacion != null) {
      final partes = fechaCreacion.split('-');
      if (partes.length == 3) {
        final fecha = DateTime(
          int.parse(partes[0]),
          int.parse(partes[1]),
          int.parse(partes[2]),
        );
        diasDesdeCreacion = DateTime.now().difference(fecha).inDays;
      }
    }

    return {
      'diasDesdeCreacion': diasDesdeCreacion,
      'vecesAlimentado': prefs.getInt(keyVecesAlimentado) ?? 0,
      'partidasJugadas': prefs.getInt(keyPartidasJugadas) ?? 0,
      'mejorPuntaje': prefs.getInt(keyMejorPuntaje) ?? 0,
      'rachaDias': prefs.getInt(keyRachaDias) ?? 0,
    };
  }

  static Future<List<String>> cargarAccesoriosDesbloqueados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(keyAccesoriosDesbloqueados) ?? [];
    } catch (error, stackTrace) {
      PrefsUtils.logError(
        'PetDataService.cargarAccesoriosDesbloqueados',
        error,
        stackTrace,
      );
      return [];
    }
  }

  static Future<void> guardarAccesorioDesbloqueado(String emoji) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actuales = prefs.getStringList(keyAccesoriosDesbloqueados) ?? [];
      if (!actuales.contains(emoji)) {
        actuales.add(emoji);
        await prefs.setStringList(keyAccesoriosDesbloqueados, actuales);
      }
    } catch (error, stackTrace) {
      PrefsUtils.logError(
        'PetDataService.guardarAccesorioDesbloqueado',
        error,
        stackTrace,
      );
    }
  }
}
