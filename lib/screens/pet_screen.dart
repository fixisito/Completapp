import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/game_data.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/stat_bar.dart';
import '../widgets/coin_badge.dart';

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
  final bool isActive;
  const PetScreen({super.key, required this.isActive});
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
  List<String> _accesoriosDesbloqueados = [];
  bool _cargando = true;
  double _shakeOffset = 0.0;

  static const comidas = [
    ComidaItem(nombre: 'Pan solo', emoji: '🍞', costo: 0, comida: 10, felicidad: 2, exp: 3),
    ComidaItem(nombre: 'Completo básico', emoji: '🌭', costo: 5, comida: 25, felicidad: 8, exp: 10),
    ComidaItem(nombre: 'Italiano', emoji: '🇮🇹', costo: 10, comida: 30, felicidad: 12, exp: 15),
    ComidaItem(nombre: 'Dinámico', emoji: '🔥', costo: 20, comida: 40, felicidad: 20, exp: 25),
    ComidaItem(nombre: 'Helado', emoji: '🍦', costo: 8, comida: 5, felicidad: 30, exp: 8),
  ];

  final List<Map<String, dynamic>> _accesoriosBase = [
    {'emoji': '🎩', 'nombre': 'Galera', 'nivelReq': 1},
    {'emoji': '🕶️', 'nombre': 'Lentes', 'nivelReq': 1},
    {'emoji': '👑', 'nombre': 'Corona', 'nivelReq': 3},
    {'emoji': '🤠', 'nombre': 'Cowboy', 'nivelReq': 5},
    {'emoji': '🎓', 'nombre': 'Graduado', 'nivelReq': 7},
    {'emoji': '🎃', 'nombre': 'Halloween', 'nivelReq': 10},
  ];

  @override
  void initState() {
    super.initState();
    _cargarEstado();
  }

  @override
  void didUpdateWidget(PetScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _cargarEstado();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarEstado() async {
    final stats = await GameData.getPetStats();
    final estadisticas = await GameData.getEstadisticas();
    final desbloqueados = await GameData.cargarAccesoriosDesbloqueados();
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
      _accesoriosDesbloqueados = desbloqueados;
      _cargando = false;
    });
    _sincronizarAccesoriosConNivel();

    if (nombrePet.isEmpty && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pedirNombre());
    }

    _inicializarTimer();
  }

  Future<void> _inicializarTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimaVez = prefs.getInt('pet_timestamp') ?? 0;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final segundosTranscurridos = ((ahora - ultimaVez) / 1000).floor();

    if (ultimaVez > 0 && segundosTranscurridos < 300) {
      final tiempoRestante = 30 - (segundosTranscurridos % 30);
      if (tiempoRestante > 0 && tiempoRestante < 30) {
        await Future.delayed(Duration(seconds: tiempoRestante));
      }
    }

    if (mounted) {
      _timer = Timer.periodic(const Duration(seconds: 30), (_) => _bajarEstados());
    }
  }

  void _sincronizarAccesoriosConNivel() {
    for (var acc in _accesoriosBase) {
      final nivelReq = acc['nivelReq'] as int;
      if (nivel >= nivelReq && !_accesoriosDesbloqueados.contains(acc['emoji'])) {
        _accesoriosDesbloqueados.add(acc['emoji']);
        GameData.guardarAccesorioDesbloqueado(acc['emoji']);
      }
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

  void _animarShake() {
    const offsets = [8.0, -8.0, 6.0, -6.0, 3.0, -3.0, 0.0];
    for (int i = 0; i < offsets.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) setState(() => _shakeOffset = offsets[i]);
      });
    }
  }

  Future<void> _alimentar(ComidaItem item) async {
    if (item.costo > 0) {
      final exito = await GameData.gastarMonedas(item.costo);
      if (!exito) {
        _animarShake();
        HapticFeedback.heavyImpact();
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
      _sincronizarAccesoriosConNivel();
      _mostrarToast('🎉 ¡$nombrePet subió al nivel $nivel!');
    }
  }

  Future<void> _recargarMonedas() async {
    final m = await GameData.getMonedas();
    if (mounted) setState(() => monedas = m);
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

  bool _accesorioDesbloqueado(Map<String, dynamic> acc) {
    final nivelReq = acc['nivelReq'] as int;
    return nivel >= nivelReq || _accesoriosDesbloqueados.contains(acc['emoji']);
  }

  void _equiparAccesorio(String emoji) {
    HapticFeedback.selectionClick();
    setState(() {
      accesorioActivo = accesorioActivo == emoji ? '' : emoji;
    });
    _guardarEstado();
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
              const Text('🌭', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: const LinearProgressIndicator(minHeight: 4, color: AppColors.verde, backgroundColor: AppColors.crema),
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
            titulo: '🌭 ${nombrePet.isEmpty ? 'Mi Completito' : nombrePet}',
            gradiente: const [AppColors.verde, Color(0xFF1d8a38)],
            accionDerecha: Row(
              children: [
                CoinBadge(monedas: monedas),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(99)),
                  child: Text('Nv.$nivel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
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

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFd0f0d8), width: 2)),
                    child: Column(
                      children: [
                        StatBar(emoji: '🍞', label: 'Comida', valor: comida, color: _colorBarra(comida)),
                        const SizedBox(height: 12),
                        StatBar(emoji: '😄', label: 'Felicidad', valor: felicidad, color: _colorBarra(felicidad)),
                        const SizedBox(height: 12),
                        StatBar(emoji: '⭐', label: 'Experiencia', valor: _expPorcentaje * 100, color: AppColors.amarillo, etiqueta: _expTexto),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Align(alignment: Alignment.centerLeft, child: Text('🍽️ Alimentar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.cafe))),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    transform: Matrix4.translationValues(_shakeOffset, 0, 0),
                    child: SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: comidas.length,
                        itemBuilder: (_, i) {
                          final c = comidas[i];
                          final puedeComprar = c.costo == 0 || monedas >= c.costo;
                          return GestureDetector(
                            onTap: () => _alimentar(c),
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Row(children: [Text(c.emoji, style: const TextStyle(fontSize: 28)), const SizedBox(width: 8), Text(c.nombre, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.cafe))]),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _effectRow('🍞 Comida', '+${c.comida.toInt()}'),
                                      _effectRow('😄 Felicidad', '+${c.felicidad.toInt()}'),
                                      _effectRow('⭐ Experiencia', '+${c.exp}'),
                                      _effectRow('🪙 Costo', c.costo == 0 ? 'Gratis' : '${c.costo} monedas'),
                                    ],
                                  ),
                                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
                                ),
                              );
                            },
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
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(c.nombre, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: puedeComprar ? AppColors.cafe : Colors.grey), textAlign: TextAlign.center),
                                  ),
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
                  ),

                  const SizedBox(height: 8),

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

                  const Align(alignment: Alignment.centerLeft, child: Text('🎽 Accesorios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.cafe))),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.1),
                    itemCount: _accesoriosBase.length,
                    itemBuilder: (_, i) {
                      final acc = _accesoriosBase[i];
                      final desbloqueado = _accesorioDesbloqueado(acc);
                      final equipado = accesorioActivo == acc['emoji'];
                      return GestureDetector(
                        onTap: desbloqueado ? () => _equiparAccesorio(acc['emoji']) : null,
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

  Widget _effectRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.cafe)),
          Text(valor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.verde)),
        ],
      ),
    );
  }
}
