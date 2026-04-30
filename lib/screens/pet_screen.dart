import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/game_data.dart';
import '../theme/app_theme.dart';

class ComidaItem {
  final String nombre;
  final String emoji;
  final int costo;
  final double comida;
  final double felicidad;
  final int exp;

  const ComidaItem({
    required this.nombre,
    required this.emoji,
    required this.costo,
    required this.comida,
    required this.felicidad,
    required this.exp,
  });
}

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});
  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  double comida = 80;
  double felicidad = 80;
  int nivel = 1;
  int exp = 0;
  int monedas = 0;
  String nombrePet = '';
  String accesorioActivo = '';
  Timer? _timer;
  double _petScale = 1.0;
  double _feedFlash = 0.0;
  bool _statsExpanded = false;
  Map<String, dynamic> _estadisticas = {};

  static const comidas = [
    ComidaItem(nombre: 'Pan solo', emoji: '🍞', costo: 0, comida: 10, felicidad: 2, exp: 3),
    ComidaItem(nombre: 'Completo básico', emoji: '🌭', costo: 5, comida: 25, felicidad: 8, exp: 10),
    ComidaItem(nombre: 'Italiano', emoji: '🇮🇹', costo: 10, comida: 30, felicidad: 12, exp: 15),
    ComidaItem(nombre: 'Dinámico', emoji: '🔥', costo: 20, comida: 40, felicidad: 20, exp: 25),
    ComidaItem(nombre: 'Helado', emoji: '🍦', costo: 8, comida: 5, felicidad: 30, exp: 8),
  ];

  final List<Map<String, dynamic>> accesorios = [
    {'emoji': '🎩', 'nombre': 'Galera', 'desbloqueado': true},
    {'emoji': '🕶️', 'nombre': 'Lentes', 'desbloqueado': true},
    {'emoji': '👑', 'nombre': 'Corona', 'desbloqueado': false, 'nivelReq': 3},
    {'emoji': '🤠', 'nombre': 'Cowboy', 'desbloqueado': false, 'nivelReq': 5},
    {'emoji': '🎓', 'nombre': 'Graduado', 'desbloqueado': false, 'nivelReq': 7},
    {'emoji': '🎃', 'nombre': 'Halloween', 'desbloqueado': false, 'nivelReq': 10},
  ];

  @override
  void initState() {
    super.initState();
    _cargarEstado();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _bajarEstados());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarEstado() async {
    final stats = await GameData.getPetStats();
    final estadisticas = await GameData.getEstadisticas();
    if (!mounted) return;
    setState(() {
      comida = stats['comida'];
      felicidad = stats['felicidad'];
      nivel = stats['nivel'];
      exp = stats['exp'];
      monedas = stats['monedas'];
      nombrePet = (stats['nombre'] as String).isEmpty ? '' : stats['nombre'];
      accesorioActivo = stats['accesorio'];
      _estadisticas = estadisticas;
    });
    _actualizarAccesorios();

    if (nombrePet.isEmpty && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pedirNombre());
    }
  }

  void _pedirNombre() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Column(
          children: [
            Text('🌭', style: TextStyle(fontSize: 60)),
            SizedBox(height: 8),
            Text('¡Hola!', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.cafe)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Cómo quieres llamar a tu completito?',
              style: TextStyle(fontSize: 14, color: AppColors.mostaza, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              maxLength: 15,
              decoration: InputDecoration(
                hintText: 'Completito',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.rojo, width: 2)),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final nombre = controller.text.trim().isEmpty ? 'Completito' : controller.text.trim();
                setState(() => nombrePet = nombre);
                GameData.setNombrePet(nombre);
                Navigator.pop(context);
              },
              child: const Text('¡Listo!'),
            ),
          ),
        ],
      ),
    );
  }

  void _editarNombre() {
    final controller = TextEditingController(text: nombrePet);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cambiar nombre', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.cafe)),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          maxLength: 15,
          decoration: InputDecoration(
            hintText: 'Completito',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.rojo, width: 2)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              final nombre = controller.text.trim().isEmpty ? 'Completito' : controller.text.trim();
              setState(() => nombrePet = nombre);
              GameData.setNombrePet(nombre);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pet_hambre', comida);
    await prefs.setDouble('pet_felicidad', felicidad);
    await prefs.setInt('pet_nivel', nivel);
    await prefs.setInt('pet_exp', exp);
    await prefs.setString('pet_accesorio', accesorioActivo);
    await prefs.setInt('pet_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  void _bajarEstados() {
    if (!mounted) return;
    setState(() {
      comida = (comida - 3).clamp(0, 100);
      felicidad = (felicidad - 2).clamp(0, 100);
    });
    _guardarEstado();
  }

  void _animarPet() {
    setState(() => _petScale = 1.2);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _petScale = 0.9);
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _petScale = 1.0);
    });
  }

  void _animarFeed() {
    setState(() => _feedFlash = 1.0);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _feedFlash = 0.0);
    });
  }

  Future<void> _alimentar(ComidaItem item) async {
    if (item.costo > 0) {
      final exito = await GameData.gastarMonedas(item.costo);
      if (!exito) {
        _mostrarToast('No tienes suficientes monedas 🪙');
        return;
      }
    }

    HapticFeedback.lightImpact();
    _animarPet();
    _animarFeed();
    GameData.registrarAlimentacion();

    setState(() {
      comida = (comida + item.comida).clamp(0, 100);
      felicidad = (felicidad + item.felicidad).clamp(0, 100);
      exp += item.exp;
      if (item.costo > 0) monedas -= item.costo;
      _subirNivel();
    });
    _guardarEstado();
    _recargarMonedas();
    _mostrarToast('${item.emoji} +${item.comida.toInt()} comida, +${item.felicidad.toInt()} felicidad');
  }

  void _jugar() {
    HapticFeedback.lightImpact();
    _animarPet();
    setState(() {
      felicidad = (felicidad + 15).clamp(0, 100);
      comida = (comida - 5).clamp(0, 100);
      exp += 5;
      _subirNivel();
    });
    _guardarEstado();
    _mostrarToast('¡$nombrePet jugó! +15 felicidad 🎉');
  }

  void _subirNivel() {
    final expNecesaria = nivel * 50;
    if (exp >= expNecesaria) {
      exp -= expNecesaria;
      nivel++;
      HapticFeedback.mediumImpact();
      _actualizarAccesorios();
      _mostrarToast('🎉 ¡$nombrePet subió al nivel $nivel!');
    }
  }

  Future<void> _recargarMonedas() async {
    final m = await GameData.getMonedas();
    if (mounted) setState(() => monedas = m);
  }

  void _actualizarAccesorios() {
    for (var acc in accesorios) {
      if (!acc['desbloqueado'] && acc.containsKey('nivelReq')) {
        if (nivel >= acc['nivelReq']) acc['desbloqueado'] = true;
      }
    }
  }

  void _mostrarToast(String mensaje) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.cafe,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _colorBarra(double valor) {
    if (valor > 60) return AppColors.verde;
    if (valor > 30) return AppColors.amarillo;
    return AppColors.rojo;
  }

  String get _estadoAnimo {
    final min = comida < felicidad ? comida : felicidad;
    if (min > 70) return '😄';
    if (min > 40) return '😐';
    return '😢';
  }

  String get _expTexto => '$exp / ${nivel * 50} XP';
  double get _expPorcentaje => (exp / (nivel * 50)).clamp(0, 1);

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
              gradient: LinearGradient(colors: [AppColors.verde, Color(0xFF1d8a38)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text('🌭 ${nombrePet.isEmpty ? 'Mi Completito' : nombrePet}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(99)),
                      child: Row(
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text('$monedas', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(99)),
                      child: Text('Nv.$nivel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // PET
                  GestureDetector(
                    onTap: () => _alimentar(comidas[0]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedOpacity(
                            opacity: _feedFlash,
                            duration: const Duration(milliseconds: 400),
                            child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.amarillo.withAlpha(60))),
                          ),
                          AnimatedScale(
                            scale: _petScale,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOutBack,
                            child: Text('🌭', style: TextStyle(fontSize: 100, shadows: [Shadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 8))])),
                          ),
                          if (accesorioActivo.isNotEmpty)
                            Positioned(top: 0, child: AnimatedScale(scale: _petScale, duration: const Duration(milliseconds: 150), child: Text(accesorioActivo, style: const TextStyle(fontSize: 40)))),
                          Positioned(bottom: 0, child: Text(_estadoAnimo, style: const TextStyle(fontSize: 28))),
                        ],
                      ),
                    ),
                  ),

                  // NOMBRE
                  GestureDetector(
                    onTap: _editarNombre,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(nombrePet.isEmpty ? 'Completito' : nombrePet,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.cafe),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit_rounded, size: 14, color: AppColors.mostaza),
                      ],
                    ),
                  ),
                  const Text('Toca para alimentar con pan gratis', style: TextStyle(fontSize: 11, color: AppColors.mostaza, fontWeight: FontWeight.w600)),

                  const SizedBox(height: 16),

                  // STATS
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFd0f0d8), width: 2)),
                    child: Column(
                      children: [
                        _statBarra('🍞 Comida', comida, _colorBarra(comida)),
                        const SizedBox(height: 12),
                        _statBarra('😄 Felicidad', felicidad, _colorBarra(felicidad)),
                        const SizedBox(height: 12),
                        _statBarra('⭐ Experiencia', _expPorcentaje * 100, AppColors.amarillo, etiqueta: _expTexto),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // COMIDAS
                  const Align(alignment: Alignment.centerLeft, child: Text('🍽️ Alimentar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.cafe))),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: comidas.length,
                      itemBuilder: (_, i) {
                        final c = comidas[i];
                        final puedeComprar = c.costo == 0 || monedas >= c.costo;
                        return GestureDetector(
                          onTap: puedeComprar ? () => _alimentar(c) : null,
                          child: Container(
                            width: 95,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: puedeComprar ? Colors.white : const Color(0xFFf5f5f5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: puedeComprar ? AppColors.naranja : const Color(0xFFe0e0e0), width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(c.emoji, style: TextStyle(fontSize: 28, color: puedeComprar ? null : const Color(0xFFcccccc))),
                                const SizedBox(height: 4),
                                Text(c.nombre, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: puedeComprar ? AppColors.cafe : Colors.grey), textAlign: TextAlign.center),
                                const SizedBox(height: 2),
                                Text(c.costo == 0 ? 'Gratis' : '${c.costo} 🪙',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: puedeComprar ? AppColors.verde : Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // JUGAR
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _jugar,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.verde,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.verde.withAlpha(89), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🎾', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 8),
                            Text('Jugar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ESTADÍSTICAS
                  GestureDetector(
                    onTap: () async {
                      final est = await GameData.getEstadisticas();
                      setState(() { _estadisticas = est; _statsExpanded = !_statsExpanded; });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFe0d0f0), width: 2)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('📊 Estadísticas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.cafe)),
                              AnimatedRotation(
                                turns: _statsExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.expand_more_rounded, color: AppColors.mostaza),
                              ),
                            ],
                          ),
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                children: [
                                  _statRow('📅 Días desde creación', '${_estadisticas['diasDesdeCreacion'] ?? 0}'),
                                  _statRow('🍞 Veces alimentado', '${_estadisticas['vecesAlimentado'] ?? 0}'),
                                  _statRow('🎮 Partidas jugadas', '${_estadisticas['partidasJugadas'] ?? 0}'),
                                  _statRow('🏆 Mejor puntaje', '${_estadisticas['mejorPuntaje'] ?? 0}'),
                                  _statRow('🔥 Racha de días', '${_estadisticas['rachaDias'] ?? 0}'),
                                ],
                              ),
                            ),
                            crossFadeState: _statsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 250),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ACCESORIOS
                  const Align(alignment: Alignment.centerLeft, child: Text('🎽 Accesorios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.cafe))),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.1),
                    itemCount: accesorios.length,
                    itemBuilder: (_, i) {
                      final acc = accesorios[i];
                      final desbloqueado = acc['desbloqueado'] as bool;
                      final equipado = accesorioActivo == acc['emoji'];
                      return GestureDetector(
                        onTap: desbloqueado ? () { HapticFeedback.selectionClick(); setState(() => accesorioActivo = equipado ? '' : acc['emoji']); _guardarEstado(); } : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: equipado ? const Color(0xFFe8f8ec) : desbloqueado ? Colors.white : const Color(0xFFf5f5f5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: equipado ? AppColors.verde : const Color(0xFFe0e0e0), width: equipado ? 3 : 2),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(acc['emoji'], style: TextStyle(fontSize: 32, color: desbloqueado ? null : const Color(0xFFcccccc))),
                                  Text(acc['nombre'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: desbloqueado ? AppColors.cafe : Colors.grey)),
                                ],
                              ),
                              if (!desbloqueado) Positioned(top: 4, right: 4, child: Text('Nv.${acc['nivelReq']}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey))),
                            ],
                          ),
                        ),
                      );
                    },
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

  Widget _statBarra(String label, double valor, Color color, {String? etiqueta}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.cafe)),
          Text(etiqueta ?? '${valor.toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mostaza)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: valor / 100),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, animVal, child) => LinearProgressIndicator(value: animVal, minHeight: 12, backgroundColor: const Color(0xFFf0f0f0), valueColor: AlwaysStoppedAnimation<Color>(color)),
          ),
        ),
      ],
    );
  }

  Widget _statRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.cafe)),
          Text(valor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.mostaza)),
        ],
      ),
    );
  }
}