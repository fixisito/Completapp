import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/calculator/calculator_domain.dart';
import '../services/game_data.dart';
import '../services/remote_price_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/counter_button.dart';

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});
  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  final TextEditingController _personasCtrl = TextEditingController(text: '0');
  List<Comensal> comensales = [];
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
    comensales = [];
    
    ingredientes = [
      Ingrediente(nombre: 'Pan de completo', emoji: '🍞', formatos: [
        FormatoCompra('Bolsa 5 uds', 5, 1150), FormatoCompra('Bolsa 8 uds', 8, 1800), FormatoCompra('Bolsa 10 uds', 10, 2300), FormatoCompra('Bolsa 24 uds', 24, 4500)
      ]),
      Ingrediente(nombre: 'Vienesa', emoji: '🌭', formatos: [
        FormatoCompra('Paquete 250g (5 uds)', 5, 1400), FormatoCompra('Paquete 500g (10 uds)', 10, 2600), FormatoCompra('Paquete 1Kg (20 uds)', 20, 5000)
      ]),
      Ingrediente(nombre: 'Palta', emoji: '🥑', formatos: [
        FormatoCompra('1 unidad', 3, 500, esUnidad: true, pesoGramos: 200), FormatoCompra('Malla 1 Kg', 15, 3000), FormatoCompra('Malla 2 Kg', 30, 5800)
      ]),
      Ingrediente(nombre: 'Tomate', emoji: '🍅', formatos: [
        FormatoCompra('1 unidad', 3, 300, esUnidad: true, pesoGramos: 200), FormatoCompra('A granel 1 Kg', 20, 1500)
      ]),
      Ingrediente(nombre: 'Mayonesa', emoji: '🫙', formatos: [
        FormatoCompra('Sachet 90g', 5, 600), FormatoCompra('Doypack 250g', 15, 1400), FormatoCompra('Doypack 400g', 25, 2200), FormatoCompra('Doypack 750g', 45, 3500), FormatoCompra('Doypack 900g', 55, 4200), FormatoCompra('Frasco 1 Kg', 60, 4800)
      ]),
      Ingrediente(nombre: 'Mostaza', emoji: '🟡', formatos: [
        FormatoCompra('Squeeze 250g', 16, 1200), FormatoCompra('Squeeze 400g', 26, 1600), FormatoCompra('Doypack 1 Kg', 66, 3200)
      ]),
      Ingrediente(nombre: 'Chucrut', emoji: '🥬', formatos: [
        FormatoCompra('Frasco 250g', 16, 1500), FormatoCompra('Frasco 500g', 33, 2800)
      ]),
      Ingrediente(nombre: 'Queso laminado', emoji: '🧀', formatos: [
        FormatoCompra('Paquete 150g (6 lams)', 6, 1800), FormatoCompra('Paquete 250g (10 lams)', 10, 2600), FormatoCompra('Paquete 500g (20 lams)', 20, 4500)
      ]),
      Ingrediente(nombre: 'Ají', emoji: '🌶️', formatos: [
        FormatoCompra('Frasco 100g', 10, 1000), FormatoCompra('Frasco 240g', 24, 2200)
      ]),
      Ingrediente(nombre: 'Salsa americana', emoji: '🔴', formatos: [
        FormatoCompra('Frasco 250g', 16, 1300), FormatoCompra('Frasco 500g', 33, 2400)
      ]),
      Ingrediente(nombre: 'Ketchup', emoji: '🍅', formatos: [
        FormatoCompra('Doypack 250g', 16, 1200), FormatoCompra('Doypack 400g', 26, 1800), FormatoCompra('Doypack 500g', 33, 2500), FormatoCompra('Doypack 1 Kg', 66, 4200)
      ]),
    ];
    _cargarPrecios();
  }

  Future<void> _cargarPrecios() async {
    final datos = await GameData.cargarDatosIngredientes();
    final bloqueados = await GameData.cargarFormatosBloqueados();
    final remotos = await RemotePriceService.fetchPricesByItems(
      ingredientes.map((ing) => ing.nombre).toList(),
    );
    if (!mounted) return;
    setState(() {
      for (var ing in ingredientes) {
        // Cargar formato bloqueado
        if (bloqueados.containsKey(ing.nombre)) {
          int index = ing.formatos.indexWhere((f) => f.nombre == bloqueados[ing.nombre]);
          if (index != -1) {
            ing.formatoSeleccionadoIndex = index;
            ing.formatoBloqueadoPorUsuario = true;
          }
        }
        
        // Cargar precios de formatos
        if (datos.containsKey(ing.nombre)) {
          for (var f in ing.formatos) {
            if (datos[ing.nombre]!.containsKey(f.nombre)) {
              f.precioActual = datos[ing.nombre]![f.nombre]!;
            }
          }
        }

        final remotePrice = remotos[ing.nombre.toLowerCase()];
        final remoteFormatIndex = remotePrice == null
            ? -1
            : ing.formatos.indexWhere((f) => f.nombre == remotePrice.formatName);
        if (remotePrice != null && remoteFormatIndex != -1) {
          ing.formatos[remoteFormatIndex].precioActual = remotePrice.price;
        }
      }
      _cargando = false;
    });
  }



  void _ajustarPersonasStr(String val) {
    int parsed = int.tryParse(val) ?? comensales.length;
    _ajustarPersonas(parsed.clamp(1, 100).toInt());
  }

  void _ajustarPersonas(int nuevasPersonas) {
    setState(() {
      while (comensales.length < nuevasPersonas) {
        comensales.add(Comensal(id: comensales.length + 1, recetaIndex: comensales.isEmpty ? 0 : comensales.first.recetaIndex));
      }
      if (comensales.length > nuevasPersonas) {
        comensales = comensales.sublist(0, nuevasPersonas);
      }
      _personasCtrl.text = comensales.length.toString();
    });
    GameData.guardarUltimosCompletos(totalCompletosGlobales);
  }

  void _asignarRecetaGlobal(int index) {
    setState(() {
      for (var c in comensales) {
        c.recetaIndex = index;
      }
    });
  }

  int get totalCompletosGlobales => comensales.fold(0, (sum, c) => sum + c.cantidadCompletos);

  Map<String, int> get _ingredientesRequeridos =>
      CalculatorEngine.ingredientesRequeridos(comensales, recetas);

  int get costoTotalGlobal =>
      CalculatorEngine.costoTotal(ingredientes, _ingredientesRequeridos);

  String formatPesos(int valor) {
    return '\$${valor.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';
  }

  void _mostrarEditorCustom(Comensal c) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Ingredientes Persona ${c.id}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.cafe)),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView(
                shrinkWrap: true,
                children: ingredientes.map((ing) {
                  final tiene = c.ingredientesCustom.contains(ing.nombre);
                  return CheckboxListTile(
                    activeColor: AppColors.rojo,
                    title: Row(
                      children: [
                        Text(ing.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(ing.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                    value: tiene,
                    onChanged: (val) {
                      setStateDialog(() {
                        if (val == true) {
                          c.ingredientesCustom.add(ing.nombre);
                        } else {
                          c.ingredientesCustom.remove(ing.nombre);
                        }
                      });
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar', style: TextStyle(color: AppColors.cafe, fontWeight: FontWeight.w800))),
            ],
          );
        }
      ),
    );
  }

  void _abrirAjustesPrecios() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Ajustes de Precios y Empaques', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.cafe)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: ingredientes.length,
                itemBuilder: (ctx, i) {
                  final ing = ingredientes[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.crema, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.amarillo, width: 2)),
                    child: Row(
                      children: [
                        Text(ing.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ing.nombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.cafe)),
                              Text('${ing.unidadCompra} - Rinde: ${ing.rendimientoActual}', style: const TextStyle(fontSize: 10, color: AppColors.mostaza)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            _editarPrecioIngrediente(ing);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.amarillo, borderRadius: BorderRadius.circular(99)),
                            child: Text(formatPesos(ing.precioActual), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.cafe)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editarPrecioIngrediente(Ingrediente ing) {
    int tempFormatoIndex = ing.formatoSeleccionadoIndex;
    final controller = TextEditingController(text: ing.formatos[tempFormatoIndex].precioActual.toString());

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
                  const Text('Formato de Compra', style: TextStyle(fontSize: 13, color: AppColors.mostaza, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(ing.formatos.length, (i) {
                      final formato = ing.formatos[i];
                      return ChoiceChip(
                        label: Text('${formato.nombre} (rinde ${formato.rendimiento})', style: const TextStyle(fontSize: 12)),
                        selected: tempFormatoIndex == i,
                        selectedColor: AppColors.naranja.withValues(alpha: 0.3),
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() {
                              tempFormatoIndex = i;
                              controller.text = ing.formatos[i].precioActual.toString();
                            });
                          }
                        },
                      );
                    }),
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
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  for (var f in ing.formatos) {
                    await prefs.remove('precio_v3_${ing.nombre}|${f.nombre}');
                    f.precioActual = f.precioBase;
                  }
                  await GameData.resetearFormatoBloqueado(ing.nombre);
                  setState(() {
                    ing.formatoBloqueadoPorUsuario = false;
                    ing.formatoSeleccionadoIndex = 0;
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    _abrirAjustesPrecios();
                  }
                },
                child: const Text('Resetear', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  final nuevo = int.tryParse(controller.text);
                  if (nuevo != null && nuevo > 0) {
                    setState(() {
                      ing.formatoSeleccionadoIndex = tempFormatoIndex;
                      ing.formatoBloqueadoPorUsuario = true;
                      ing.formatoActual.precioActual = nuevo;
                    });
                    GameData.guardarDatosIngrediente(ing.nombre, ing.formatoActual.nombre, nuevo);
                    GameData.guardarFormatoBloqueado(ing.nombre, ing.formatoActual.nombre);
                  }
                  Navigator.pop(context);
                  _abrirAjustesPrecios();
                },
                child: const Text('Guardar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
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

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(backgroundColor: AppColors.blanco, body: Center(child: CircularProgressIndicator(color: AppColors.rojo)));
    }

    final reqs = _ingredientesRequeridos;
    for (var ing in ingredientes) {
      ing.autoSeleccionarFormato(reqs[ing.nombre] ?? 0);
    }
    final totalAproxUnidad = totalCompletosGlobales > 0 ? (costoTotalGlobal / totalCompletosGlobales).ceil() : 0;

    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: Column(
        children: [
          GradientHeader(titulo: '🧮 Calculadora', gradiente: const [AppColors.rojo, AppColors.naranja]),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECCIÓN A: Configuración Global ---
                  _seccionTitulo('👥 ¿Cuántas personas comerán?'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.crema, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.amarillo, width: 2)),
                    child: Row(
                      children: [
                        _botonContador(Icons.remove, AppColors.rojo, () => _ajustarPersonas(comensales.length - 1)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _personasCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.cafe),
                            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                            onSubmitted: _ajustarPersonasStr,
                            onTapOutside: (_) => _ajustarPersonasStr(_personasCtrl.text),
                          ),
                        ),
                        const SizedBox(width: 16),
                        _botonContador(Icons.add, AppColors.verde, () => _ajustarPersonas(comensales.length + 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Asignación rápida (A todos):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mostaza)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(recetas.length, (i) {
                        final r = recetas[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _asignarRecetaGlobal(i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(color: const Color(0xFFe0d0b0), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Text(r.emoji, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(r.nombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.cafe)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 32),
                  // --- SECCIÓN B: Detalle por Persona ---
                  _seccionTitulo('👤 Detalle por Persona'),
                  const SizedBox(height: 10),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: comensales.length,
                    itemBuilder: (ctx, i) {
                      final c = comensales[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFf0e0c0), width: 2)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Persona ${c.id}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.cafe, fontSize: 14)),
                                const Spacer(),
                                CounterButton(
                                  valor: c.cantidadCompletos,
                                  onDecrement: () => setState(() => c.cantidadCompletos = (c.cantidadCompletos - 1).clamp(0, 10).toInt()),
                                  onIncrement: () => setState(() => c.cantidadCompletos = (c.cantidadCompletos + 1).clamp(0, 10).toInt()),
                                  label: 'uds',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text('Receta:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 36,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(color: AppColors.crema, borderRadius: BorderRadius.circular(8)),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: c.recetaIndex,
                                        isExpanded: true,
                                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.rojo),
                                        items: List.generate(recetas.length, (ri) => DropdownMenuItem(
                                          value: ri,
                                          child: Text('${recetas[ri].emoji} ${recetas[ri].nombre}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.cafe)),
                                        )),
                                        onChanged: (val) {
                                          if (val != null) setState(() => c.recetaIndex = val);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                if (c.recetaIndex == 3) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _mostrarEditorCustom(c),
                                    child: Container(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(color: AppColors.amarillo, borderRadius: BorderRadius.circular(8)),
                                      child: const Center(child: Text('Editar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.cafe))),
                                    ),
                                  ),
                                ],
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  // --- SECCIÓN C: Lista de Compras y Resumen ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _seccionTitulo('🛒 Lista Consolidada'),
                      GestureDetector(
                        onTap: _abrirAjustesPrecios,
                        child: const Row(
                          children: [
                            Icon(Icons.settings, size: 16, color: AppColors.rojo),
                            SizedBox(width: 4),
                            Text('Ajustar Precios', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.rojo)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (totalCompletosGlobales == 0)
                    const Text('Nadie va a comer completos 😔', style: TextStyle(color: Colors.grey))
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFd0f0d8), width: 2)),
                      child: Column(
                        children: ingredientes.map((ing) {
                          final cant = reqs[ing.nombre] ?? 0;
                          if (cant == 0) return const SizedBox.shrink();
                          final udsComprar = ing.unidadesNecesarias(cant);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Text(ing.emoji, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (ing.formatoActual.esUnidad)
                                        Text('$udsComprar ${udsComprar == 1 ? 'unidad' : 'unidades'} de ${ing.nombre}${ing.formatoActual.pesoGramos != null ? ' (~${(ing.formatoActual.pesoGramos! * udsComprar >= 1000) ? '${((ing.formatoActual.pesoGramos! * udsComprar) / 1000.0).toStringAsFixed(1)} Kg' : '${ing.formatoActual.pesoGramos! * udsComprar}g'})' : ''}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.cafe))
                                      else
                                        Text('$udsComprar × ${ing.formatoActual.nombre} de ${ing.nombre}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.cafe)),
                                      Text('Rinde para ${ing.rendimientoActual * udsComprar} completos', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Text(formatPesos(ing.costoPara(cant)), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.verde)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 20),
                  _seccionTitulo('📋 Resumen Final'),
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
                        _filaResumen('👥 Personas', '${comensales.length}'),
                        _filaResumen('🌭 Total completos', '$totalCompletosGlobales'),
                        _filaResumen('💵 Costo aprox. por unidad', formatPesos(totalAproxUnidad)),
                        const Divider(color: Colors.white30, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('💰 Gran Total', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                            Text(formatPesos(costoTotalGlobal), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text('(Comprando empaques completos)', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
