import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  int personas = 2;
  List<int> completosPorPersona = [2, 1];

  // Precios base reales Chile 2025 (en pesos)
  final Map<String, int> preciosBase = {
    'Pan marraqueta': 150,
    'Vienesa': 400,
    'Palta': 300,
    'Tomate': 150,
    'Mayonesa': 80,
    'Mostaza': 50,
    'Chucrut': 120,
    'Queso': 200,
    'Ají': 30,
  };

  late Map<String, int> precios;
  late Map<String, bool> ingredientesActivos;

  @override
  void initState() {
    super.initState();
    precios = Map.from(preciosBase);
    ingredientesActivos = {
      for (var k in preciosBase.keys) k: ['Pan marraqueta', 'Vienesa', 'Palta', 'Tomate', 'Mayonesa'].contains(k)
    };
    _cargarPrecios();
  }

  Future<void> _guardarUltimoTotal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ultimos_completos', totalCompletos);
  }

  Future<void> _cargarPrecios() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var key in precios.keys) {
        final guardado = prefs.getInt('precio_$key');
        if (guardado != null) precios[key] = guardado;
      }
    });
  }

  Future<void> _guardarPrecio(String key, int valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('precio_$key', valor);
  }

  void cambiarPersonas(int delta) {
    setState(() {
      personas = (personas + delta).clamp(1, 20);
      while (completosPorPersona.length < personas) completosPorPersona.add(1);
      completosPorPersona = completosPorPersona.sublist(0, personas);
    });
    _guardarUltimoTotal();
  }

  void cambiarCompletos(int index, int delta) {
    setState(() {
      completosPorPersona[index] = (completosPorPersona[index] + delta).clamp(1, 10);
    });
    _guardarUltimoTotal();
  }

  int get totalCompletos => completosPorPersona.fold(0, (a, b) => a + b);

  int get costoPorCompleto {
    int costo = 0;
    ingredientesActivos.forEach((key, activo) {
      if (activo) costo += precios[key]!;
    });
    return costo;
  }

  int get costoTotal => totalCompletos * costoPorCompleto;

  String formatPesos(int valor) {
    return '\$${valor.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';
  }

  void _editarPrecio(String ingrediente) {
    final controller = TextEditingController(text: precios[ingrediente].toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          ingrediente,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.cafe,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Precio por unidad (CLP)',
              style: TextStyle(fontSize: 13, color: AppColors.mostaza, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.rojo, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Precio base: ${formatPesos(preciosBase[ingrediente]!)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => precios[ingrediente] = preciosBase[ingrediente]!);
              _guardarPrecio(ingrediente, preciosBase[ingrediente]!);
              Navigator.pop(context);
            },
            child: const Text('Resetear', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rojo,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final nuevo = int.tryParse(controller.text);
              if (nuevo != null && nuevo >= 0) {
                setState(() => precios[ingrediente] = nuevo);
                _guardarPrecio(ingrediente, nuevo);
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.rojo, AppColors.naranja],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: const Text(
              '🧮 Calculadora',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // PERSONAS
                  _seccionTitulo('👥 Personas'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.crema,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.amarillo, width: 2),
                    ),
                    child: Row(
                      children: [
                        _botonContador(Icons.remove, AppColors.rojo, () => cambiarPersonas(-1)),
                        Expanded(
                          child: Center(
                            child: Text('$personas',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.cafe),
                            ),
                          ),
                        ),
                        _botonContador(Icons.add, AppColors.verde, () => cambiarPersonas(1)),
                        const SizedBox(width: 10),
                        const Text('personas',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mostaza),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  _seccionTitulo('🌭 Completos por persona'),
                  const SizedBox(height: 10),

                  ...List.generate(personas, (i) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFf0e0c0), width: 2),
                    ),
                    child: Row(
                      children: [
                        Text('👤 Persona ${i + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.cafe, fontSize: 14),
                        ),
                        const Spacer(),
                        _miniContador(
                          valor: completosPorPersona[i],
                          onMenos: () => cambiarCompletos(i, -1),
                          onMas: () => cambiarCompletos(i, 1),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _seccionTitulo('🧄 Ingredientes'),
                      const Spacer(),
                      const Text('Toca el precio para editar',
                        style: TextStyle(fontSize: 11, color: AppColors.mostaza, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ...precios.keys.map((ing) {
                    final activo = ingredientesActivos[ing]!;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: activo ? AppColors.crema : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: activo ? AppColors.amarillo : const Color(0xFFf0e0c0),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => ingredientesActivos[ing] = !activo),
                            child: Icon(
                              activo ? Icons.check_circle_rounded : Icons.circle_outlined,
                              color: activo ? AppColors.verde : Colors.grey,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(ing,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: activo ? AppColors.cafe : Colors.grey,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _editarPrecio(ing),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: activo ? AppColors.amarillo : const Color(0xFFf0f0f0),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                formatPesos(precios[ing]!),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: activo ? AppColors.cafe : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 20),
                  _seccionTitulo('📋 Resumen'),
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.rojo, AppColors.naranja],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _filaResumen('👥 Personas', '$personas'),
                        _filaResumen('🌭 Total completos', '$totalCompletos'),
                        _filaResumen('💵 Costo por completo', formatPesos(costoPorCompleto)),
                        const Divider(color: Colors.white30, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('💰 Total',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            Text(formatPesos(costoTotal),
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccionTitulo(String texto) => Text(texto,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.cafe));

  Widget _botonContador(IconData icono, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icono, color: Colors.white, size: 20),
        ),
      );

  Widget _miniContador({required int valor, required VoidCallback onMenos, required VoidCallback onMas}) =>
      Row(children: [
        GestureDetector(
          onTap: onMenos,
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: const Color(0xFFf5e8d0), borderRadius: BorderRadius.circular(99)),
            child: const Icon(Icons.remove, size: 16, color: AppColors.cafe),
          ),
        ),
        SizedBox(
          width: 32,
          child: Center(child: Text('$valor',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.cafe))),
        ),
        GestureDetector(
          onTap: onMas,
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: const Color(0xFFf5e8d0), borderRadius: BorderRadius.circular(99)),
            child: const Icon(Icons.add, size: 16, color: AppColors.cafe),
          ),
        ),
        const SizedBox(width: 8),
        Text(valor == 1 ? 'completo' : 'completos',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mostaza)),
      ]);

  Widget _filaResumen(String label, String valor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
        Text(valor, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
      ],
    ),
  );
}