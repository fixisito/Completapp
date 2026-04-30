import 'package:shared_preferences/shared_preferences.dart';

class GameData {
  static const _keyMonedas = 'monedas';
  static const _keyNombrePet = 'pet_nombre';
  static const _keyComida = 'pet_hambre';
  static const _keyFelicidad = 'pet_felicidad';
  static const _keyNivel = 'pet_nivel';
  static const _keyExp = 'pet_exp';
  static const _keyAccesorio = 'pet_accesorio';
  static const _keyTimestamp = 'pet_timestamp';
  static const _keyMejorPuntaje = 'mejor_puntaje_atrapa';

  static const _keyVecesAlimentado = 'stats_veces_alimentado';
  static const _keyPartidasJugadas = 'stats_partidas_jugadas';
  static const _keyFechaCreacion = 'stats_fecha_creacion';
  static const _keyUltimaVisita = 'stats_ultima_visita';
  static const _keyRachaDias = 'stats_racha_dias';

  // --- Monedas ---
  static Future<int> getMonedas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMonedas) ?? 0;
  }

  static Future<void> agregarMonedas(int cantidad) async {
    final prefs = await SharedPreferences.getInstance();
    final actual = prefs.getInt(_keyMonedas) ?? 0;
    await prefs.setInt(_keyMonedas, actual + cantidad);
  }

  static Future<bool> gastarMonedas(int cantidad) async {
    final prefs = await SharedPreferences.getInstance();
    final actual = prefs.getInt(_keyMonedas) ?? 0;
    if (actual < cantidad) return false;
    await prefs.setInt(_keyMonedas, actual - cantidad);
    return true;
  }

  // --- Nombre del Pet ---
  static Future<String> getNombrePet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNombrePet) ?? '';
  }

  static Future<void> setNombrePet(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNombrePet, nombre);
  }

  // --- Stats del Pet ---
  static Future<Map<String, dynamic>> getPetStats() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimaVez = prefs.getInt(_keyTimestamp) ?? 0;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final segundosPasados = ((ahora - ultimaVez) / 1000).floor();

    double comida = (prefs.getDouble(_keyComida) ?? 80) - (segundosPasados / 30) * 3;
    double felicidad = (prefs.getDouble(_keyFelicidad) ?? 80) - (segundosPasados / 30) * 2;

    return {
      'comida': comida.clamp(0.0, 100.0),
      'felicidad': felicidad.clamp(0.0, 100.0),
      'nivel': prefs.getInt(_keyNivel) ?? 1,
      'exp': prefs.getInt(_keyExp) ?? 0,
      'accesorio': prefs.getString(_keyAccesorio) ?? '',
      'monedas': prefs.getInt(_keyMonedas) ?? 0,
      'nombre': prefs.getString(_keyNombrePet) ?? '',
    };
  }

  // --- Estadísticas ---
  static Future<void> registrarAlimentacion() async {
    final prefs = await SharedPreferences.getInstance();
    final veces = prefs.getInt(_keyVecesAlimentado) ?? 0;
    await prefs.setInt(_keyVecesAlimentado, veces + 1);
  }

  static Future<void> registrarPartida() async {
    final prefs = await SharedPreferences.getInstance();
    final partidas = prefs.getInt(_keyPartidasJugadas) ?? 0;
    await prefs.setInt(_keyPartidasJugadas, partidas + 1);
  }

  static Future<void> verificarRachaDiaria() async {
    final prefs = await SharedPreferences.getInstance();
    final ahora = DateTime.now();
    final hoyStr = '${ahora.year}-${ahora.month}-${ahora.day}';
    final ultimaVisita = prefs.getString(_keyUltimaVisita) ?? '';

    if (ultimaVisita == hoyStr) return;

    if (prefs.getString(_keyFechaCreacion) == null) {
      await prefs.setString(_keyFechaCreacion, hoyStr);
    }

    final ayer = ahora.subtract(const Duration(days: 1));
    final ayerStr = '${ayer.year}-${ayer.month}-${ayer.day}';

    int racha = prefs.getInt(_keyRachaDias) ?? 0;
    if (ultimaVisita == ayerStr) {
      racha++;
    } else if (ultimaVisita.isNotEmpty) {
      racha = 1;
    } else {
      racha = 1;
    }

    await prefs.setString(_keyUltimaVisita, hoyStr);
    await prefs.setInt(_keyRachaDias, racha);
  }

  static Future<Map<String, dynamic>> getEstadisticas() async {
    final prefs = await SharedPreferences.getInstance();
    final fechaCreacion = prefs.getString(_keyFechaCreacion);
    int diasDesdeCreacion = 0;
    if (fechaCreacion != null) {
      final partes = fechaCreacion.split('-');
      if (partes.length == 3) {
        final fecha = DateTime(int.parse(partes[0]), int.parse(partes[1]), int.parse(partes[2]));
        diasDesdeCreacion = DateTime.now().difference(fecha).inDays;
      }
    }

    return {
      'diasDesdeCreacion': diasDesdeCreacion,
      'vecesAlimentado': prefs.getInt(_keyVecesAlimentado) ?? 0,
      'partidasJugadas': prefs.getInt(_keyPartidasJugadas) ?? 0,
      'mejorPuntaje': prefs.getInt(_keyMejorPuntaje) ?? 0,
      'rachaDias': prefs.getInt(_keyRachaDias) ?? 0,
    };
  }
}
