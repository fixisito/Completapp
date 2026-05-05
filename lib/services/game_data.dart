import 'calculadora_data_service.dart';
import 'juego_data_service.dart';
import 'pet_data_service.dart';

class GameData {
  static Future<int> getMonedas() async {
    return PetDataService.getMonedas();
  }

  static Future<void> agregarMonedas(int cantidad) async {
    await PetDataService.agregarMonedas(cantidad);
  }

  static Future<bool> gastarMonedas(int cantidad) async {
    return PetDataService.gastarMonedas(cantidad);
  }

  static Future<String> getNombrePet() async {
    return PetDataService.getNombrePet();
  }

  static Future<void> setNombrePet(String nombre) async {
    await PetDataService.setNombrePet(nombre);
  }

  static Future<Map<String, dynamic>> getPetStats() async {
    return PetDataService.getPetStats();
  }

  static Future<void> registrarAlimentacion() async {
    await PetDataService.registrarAlimentacion();
  }

  static Future<void> registrarPartida() async {
    await PetDataService.registrarPartida();
  }

  static Future<void> verificarRachaDiaria() async {
    await PetDataService.verificarRachaDiaria();
  }

  static Future<Map<String, dynamic>> getEstadisticas() async {
    return PetDataService.getEstadisticas();
  }

  static Future<Map<String, Map<String, int>>> cargarDatosIngredientes() async {
    return CalculadoraDataService.cargarDatosIngredientes();
  }

  static Future<void> guardarDatosIngrediente(String ingrediente, String formato, int precio) async {
    await CalculadoraDataService.guardarDatosIngrediente(
      ingrediente,
      formato,
      precio,
    );
  }

  static Future<Map<String, String>> cargarFormatosBloqueados() async {
    return CalculadoraDataService.cargarFormatosBloqueados();
  }

  static Future<void> guardarFormatoBloqueado(String ingrediente, String formato) async {
    await CalculadoraDataService.guardarFormatoBloqueado(ingrediente, formato);
  }

  static Future<void> resetearFormatoBloqueado(String ingrediente) async {
    await CalculadoraDataService.resetearFormatoBloqueado(ingrediente);
  }

  static Future<int> cargarUltimosCompletos() async {
    return CalculadoraDataService.cargarUltimosCompletos();
  }

  static Future<void> guardarUltimosCompletos(int total) async {
    await CalculadoraDataService.guardarUltimosCompletos(total);
  }

  static Future<int> cargarMejorPuntaje() async {
    return JuegoDataService.cargarMejorPuntaje();
  }

  static Future<void> guardarMejorPuntaje(int puntaje) async {
    await JuegoDataService.guardarMejorPuntaje(puntaje);
  }

  static Future<List<String>> cargarAccesoriosDesbloqueados() async {
    return PetDataService.cargarAccesoriosDesbloqueados();
  }

  static Future<void> guardarAccesorioDesbloqueado(String emoji) async {
    await PetDataService.guardarAccesorioDesbloqueado(emoji);
  }
}
