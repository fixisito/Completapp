import 'package:flutter/material.dart';
import '../services/game_data.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/counter_button.dart';

class Ingrediente {
  final String nombre;
  final String emoji;
  final String unidadCompra;
  final int precioBase;
  final int rendimientoBase;
  final List<int> opcionesRendimiento;
  int precioActual;
  int rendimientoActual;
  bool activo;

  Ingrediente({
    required this.nombre,
    required this.emoji,
    required this.unidadCompra,
    required this.precioBase,
    required this.rendimientoBase,
    this.opcionesRendimiento = const [],
    int? precioActual,
    int? rendimientoActual,
    this.activo = false,
  }) : precioActual = precioActual ?? precioBase,
       rendimientoActual = rendimientoActual ?? rendimientoBase;

  double get costoPorCompleto => precioActual / rendimientoActual;
  int unidadesNecesarias(int totalCompletos) => (totalCompletos / rendimientoActual).ceil();
  int costoParaCompletos(int totalCompletos) => unidadesNecesarias(totalCompletos) * precioActual;
}

class Receta {
  final String nombre;
  final String emoji;
  final List<String> ingredientes;
  const Receta({required this.nombre, required this.emoji, required this.ingredientes});
}

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});
  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  int personas = 2;
  List<int> completosPorPersona = [2, 1];
  int recetaSeleccionada = 0;
  bool _cargando = true;

  static const recetas = [
    Receta(nombre: 'Italiano', emoji: '🇮🇹', ingredientes: ['Pan de completo', 'Vienesa', 'Palta', 'Tomate', 'Mayonesa']),
    Receta(nombre: 'Completo', emoji: '🌭', ingredientes: ['Pan de completo', 'Vienesa', 'Tomate', 'Mayonesa', 'Chucrut', 'Salsa americana']),
    Receta(nombre: 'Dinámico', emoji: '🔥', ingredientes: ['Pan de completo', 'Vienesa', 'Palta', 'Tomate', 'Mayonesa', 'Chucrut', 'Salsa americana', 'Ketchup']),
    Receta(nombre: 'Custom', emoji: '✏️', ingredientes: []),
  ];

  late List<Ingrediente> ingredientes;

  @override
  void initState() {
    super.initState();
    ingredientes = [
      Ingrediente(nombre: 'Pan de completo', emoji: '🍞', unidadCompra: 'Paquetes', precioBase: 2300, rendimientoBase: 10, opcionesRendimiento: [5, 6, 8, 10, 20]),
      Ingrediente(nombre: 'Vienesa', emoji: '🌭', unidadCompra: 'Paquetes', precioBase: 1400, rendimientoBase: 5, opcionesRendimiento: [5, 10, 20]),
      Ingrediente(nombre: 'Palta', emoji: '🥑', unidadCompra: 'A granel (uds)', precioBase: 1200, rendimientoBase: 4, opcionesRendimiento: [2, 3, 4, 5, 8]),
      Ingrediente(nombre: 'Tomate', emoji: '🍅', unidadCompra: 'A granel (uds)', precioBase: 400, rendimientoBase: 5, opcionesRendimiento: [3, 4, 5, 6, 10]),
      Ingrediente(nombre: 'Mayonesa', emoji: '🫙', unidadCompra: 'Doypack', precioBase: 2200, rendimientoBase: 25, opcionesRendimiento: [10, 15, 25, 40]),
      Ingrediente(nombre: 'Mostaza', emoji: '🟡', unidadCompra: 'Squeeze', precioBase: 1600, rendimientoBase: 25, opcionesRendimiento: [10, 15, 25, 40]),
      Ingrediente(nombre: 'Chucrut', emoji: '🥬', unidadCompra: 'Frasco', precioBase: 1500, rendimientoBase: 10, opcionesRendimiento: [5, 10, 15, 20]),
      Ingrediente(nombre: 'Queso laminado', emoji: '🧀', unidadCompra: 'Paquete', precioBase: 3700, rendimientoBase: 10, opcionesRendimiento: [10, 15, 20]),
      Ingrediente(nombre: 'Ají', emoji: '🌶️', unidadCompra: 'Frasco', precioBase: 1400, rendimientoBase: 20, opcionesRendimiento: [10, 20, 30]),
      Ingrediente(nombre: 'Salsa americana', emoji: '🔴', unidadCompra: 'Frasco', precioBase: 1300, rendimientoBase: 20, opcionesRendimiento: [10, 20, 30]),
      Ingrediente(nombre: 'Ketchup', emoji: '🍅', unidadCompra: 'Doypack', precioBase: 2500, rendimientoBase: 25, opcionesRendimiento: [10, 15, 25, 40]),
    ];
    _cargarPrecios();
    _aplicarReceta(0);
  }

  Future<void> _cargarPrecios() async {
    final datos = await GameData.cargarDatosIngredientes();
    if (!mounted) return;
    setState(() {
      for (var ing in ingredientes) {
        if (datos.containsKey(ing.nombre)) {
          ing.precioActual = datos[ing.nombre]!['precio']!;
          if (datos[ing.nombre]!.containsKey('rendimiento')) {
            ing.rendimientoActual = datos[ing.nombre]!['rendimiento']!;
          }
        }
      }
      _cargando = false;
    });
  }

  Future<void> _guardarDatos(Ingrediente ing) async {
    await GameData.guardarDatosIngrediente(ing.nombre, ing.precioActual, ing.rendimientoActual);
  }

  Future<void> _guardarUltimoTotal() async {
    await GameData.guardarUltimosCompletos(totalCompletos);
  }

  void _aplicarReceta(int index) {
    setState(() {
      recetaSeleccionada = index;
      if (index < 3) {
        final receta = recetas[index];
        for (var ing in ingredientes) {
          ing.activo = receta.ingredientes.contains(ing.nombre);
        }
      }
    });
  }

  void cambiarPersonas(int delta) {
    setState(() {
      personas = (personas + delta).clamp(1, 20);
      while (completosPorPersona.length < personas) {
        completosPorPersona.add(1);
      }
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

  List<Ingrediente> get activos => ingredientes.where((i) => i.activo).toList();

  int get costoPorCompleto {
    double costo = 0;
    for (var ing in activos) {
      costo += ing.costoPorCompleto;
    }
    return costo.ceil();
  }

  int get costoTotalReal {
    int total = 0;
    for (var ing in activos) {
      total += ing.costoParaCompletos(totalCompletos);
    }
    return total;
  }

  String formatPesos(int valor) {
    return '\$${valor.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';
  }

  void _editarPrecio(Ingrediente ing) {
    final controller = TextEditingController(text: ing.precioActual.toString());
    int tempRendimiento = ing.rendimientoActual;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Text(ing.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(child: Text(ing.nombre, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.cafe, fontSize: 16))),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rendimiento (Unidades/Pack)', style: TextStyle(fontSize: 13, color: AppColors.mostaza, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...ing.opcionesRendimiento.map((opcion) => ChoiceChip(
                        label: Text('$opcion', style: const TextStyle(fontSize: 12)),
                        selected: tempRendimiento == opcion,
                        selectedColor: AppColors.naranja.withValues(alpha: 0.3),
                        onSelected: (selected) {
                          if (selected) setDialogState(() => tempRendimiento = opcion);
                        },
                      )),
                      if (!ing.opcionesRendimiento.contains(tempRendimiento))
                        ChoiceChip(
                          label: Text('$tempRendimiento (Custom)', style: const TextStyle(fontSize: 12)),
                          selected: true,
                          selectedColor: AppColors.naranja.withValues(alpha: 0.3),
                          onSelected: (_) {},
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Precio de compra', style: TextStyle(fontSize: 13, color: AppColors.mostaza, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.rojo, width: 2)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    ing.precioActual = ing.precioBase;
                    ing.rendimientoActual = ing.rendimientoBase;
                  });
                  _guardarDatos(ing);
                  Navigator.pop(context);
                },
                child: const Text('Resetear', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  final nuevo = int.tryParse(controller.text);
                  if (nuevo != null && nuevo >= 0) {
                    setState(() {
                      ing.precioActual = nuevo;
                      ing.rendimientoActual = tempRendimiento;
                    });
                    _guardarDatos(ing);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Guardar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        backgroundColor: AppColors.blanco,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🧮', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: const LinearProgressIndicator(minHeight: 4, color: AppColors.rojo, backgroundColor: AppColors.crema),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: Column(
        children: [
          GradientHeader(
            titulo: '🧮 Calculadora',
            gradiente: const [AppColors.rojo, AppColors.naranja],
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _seccionTitulo('👥 Personas'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.crema, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.amarillo, width: 2)),
                    child: Row(
                      children: [
                        _botonContador(Icons.remove, AppColors.rojo, () => cambiarPersonas(-1)),
                        Expanded(child: Center(child: Text('$personas', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.cafe)))),
                        _botonContador(Icons.add, AppColors.verde, () => cambiarPersonas(1)),
                        const SizedBox(width: 10),
                        const Text('personas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mostaza)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  _seccionTitulo('🌭 Completos por persona'),
                  const SizedBox(height: 10),
                  ...List.generate(personas, (i) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFf0e0c0), width: 2)),
                    child: Row(
                      children: [
                        Text('👤 Persona ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.cafe, fontSize: 14)),
                        const Spacer(),
                        CounterButton(
                          valor: completosPorPersona[i],
                          onDecrement: () => cambiarCompletos(i, -1),
                          onIncrement: () => cambiarCompletos(i, 1),
                          label: completosPorPersona[i] == 1 ? 'completo' : 'completos',
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 20),
                  _seccionTitulo('📖 Tipo de completo'),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(recetas.length, (i) {
                        final r = recetas[i];
                        final selected = recetaSeleccionada == i;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _aplicarReceta(i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.rojo : Colors.white,
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(color: selected ? AppColors.rojo : const Color(0xFFe0d0b0), width: 2),
                              ),
                              child: Row(
                                children: [
                                  Text(r.emoji, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 6),
                                  Text(r.nombre, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: selected ? Colors.white : AppColors.cafe)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _seccionTitulo('🧄 Ingredientes'),
                      const Spacer(),
                      const Text('Toca precio para editar', style: TextStyle(fontSize: 10, color: AppColors.mostaza, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...ingredientes.map((ing) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: ing.activo ? AppColors.crema : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ing.activo ? AppColors.amarillo : const Color(0xFFf0e0c0), width: 2),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                ing.activo = !ing.activo;
                                recetaSeleccionada = 3;
                              });
                            },
                            child: Icon(ing.activo ? Icons.check_circle_rounded : Icons.circle_outlined, color: ing.activo ? AppColors.verde : Colors.grey, size: 22),
                          ),
                          const SizedBox(width: 8),
                          Text(ing.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ing.nombre, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: ing.activo ? AppColors.cafe : Colors.grey)),
                                Text(ing.unidadCompra, style: TextStyle(fontSize: 10, color: ing.activo ? AppColors.mostaza : Colors.grey)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _editarPrecio(ing),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: ing.activo ? AppColors.amarillo : const Color(0xFFf0f0f0), borderRadius: BorderRadius.circular(99)),
                              child: Text(formatPesos(ing.precioActual), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: ing.activo ? AppColors.cafe : Colors.grey)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  if (activos.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _seccionTitulo('🛒 Lista de compras'),
                    const SizedBox(height: 4),
                    Text('Para $totalCompletos completos necesitas:', style: const TextStyle(fontSize: 12, color: AppColors.mostaza, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFd0f0d8), width: 2),
                      ),
                      child: Column(
                        children: activos.map((ing) {
                          final uds = ing.unidadesNecesarias(totalCompletos);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text(ing.emoji, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(child: Text('$uds × ${ing.nombre}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.cafe))),
                                Text(formatPesos(ing.costoParaCompletos(totalCompletos)), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.mostaza)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  _seccionTitulo('📋 Resumen'),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.rojo, AppColors.naranja], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _filaResumen('👥 Personas', '$personas'),
                        _filaResumen('🌭 Total completos', '$totalCompletos'),
                        _filaResumen('💵 Costo aprox. por completo', formatPesos(costoPorCompleto)),
                        const Divider(color: Colors.white30, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('💰 Total a gastar', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                            Text(formatPesos(costoTotalReal), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text('(Comprando unidades completas)', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600)),
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

  Widget _seccionTitulo(String texto) => Text(texto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.cafe));

  Widget _botonContador(IconData icono, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(width: 40, height: 40, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(icono, color: Colors.white, size: 20)),
      );

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
