import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../services/game_data.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/coin_badge.dart';

enum TipoItem { completo, dorado, cebolla }

class _Item {
  final int id;
  final TipoItem tipo;
  final double x;
  double y;
  final double velocidad;

  _Item({required this.id, required this.tipo, required this.x, required this.y, required this.velocidad});

  String get emoji {
    switch (tipo) {
      case TipoItem.completo: return '🌭';
      case TipoItem.dorado: return '⭐';
      case TipoItem.cebolla: return '🧅';
    }
  }

  double get size {
    switch (tipo) {
      case TipoItem.dorado: return 52;
      default: return 48;
    }
  }
}

class JuegosScreen extends StatefulWidget {
  final bool isActive;
  const JuegosScreen({super.key, this.isActive = true});
  @override
  State<JuegosScreen> createState() => _JuegosScreenState();
}

class _JuegosScreenState extends State<JuegosScreen> with SingleTickerProviderStateMixin {
  bool jugando = false;
  bool pausado = false;
  int puntaje = 0;
  int mejorPuntaje = 0;
  int vidas = 3;
  int monedasGanadas = 0;

  late Ticker _ticker;
  Duration _lastTime = Duration.zero;
  double _timeSinceLastSpawn = 0;

  final Random _random = Random();

  List<_Item> items = [];
  double areaAncho = 0;
  double areaAlto = 0;
  bool _cargando = true;
  final List<_FloatingText> _floatingTexts = [];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _cargarMejorPuntaje();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(JuegosScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isActive && jugando && !pausado) {
      _pausarJuego();
    }
  }

  void _onTick(Duration elapsed) {
    if (!jugando || pausado || areaAncho == 0) return;

    final dt = (elapsed.inMilliseconds - _lastTime.inMilliseconds) / 1000.0;
    _lastTime = elapsed;

    if (dt > 0.1) return; // Prevent big jumps if lag

    _timeSinceLastSpawn += dt;
    final double spawnIntervalSeconds = _spawnInterval / 1000.0;

    if (_timeSinceLastSpawn >= spawnIntervalSeconds) {
      _timeSinceLastSpawn = 0;
      _spawnItem();
    }

    _moverItems(dt);
  }

  Future<void> _cargarMejorPuntaje() async {
    final puntaje = await GameData.cargarMejorPuntaje();
    if (!mounted) return;
    setState(() {
      mejorPuntaje = puntaje;
      _cargando = false;
    });
  }

  Future<void> _guardarMejorPuntaje() async {
    if (puntaje > mejorPuntaje) {
      await GameData.guardarMejorPuntaje(puntaje);
    }
  }

  void _iniciarJuego() {
    GameData.registrarPartida();
    setState(() {
      jugando = true;
      pausado = false;
      puntaje = 0;
      vidas = 3;
      monedasGanadas = 0;
      items = [];
      _timeSinceLastSpawn = 0;
      _lastTime = Duration.zero;
    });
    _ticker.start();
  }

  void _pausarJuego() {
    if (!jugando || pausado) return;
    setState(() => pausado = true);
    _ticker.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('⏸️ Pausa', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.cafe), textAlign: TextAlign.center),
        content: const Text('El juego está pausado.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _terminarJuego(mostrarDialogo: false);
                  },
                  child: const Text('Salir', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.verde, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () {
                    Navigator.pop(context);
                    _reanudarJuego();
                  },
                  child: const Text('Continuar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _reanudarJuego() {
    setState(() => pausado = false);
    _lastTime = Duration.zero; 
    _ticker.start();
  }

  int get _spawnInterval {
    if (puntaje > 30) return 700;
    if (puntaje > 20) return 850;
    if (puntaje > 10) return 1000;
    return 1200;
  }

  TipoItem _tipoAleatorio() {
    final roll = _random.nextDouble();
    if (puntaje >= 25 && roll < 0.12) return TipoItem.dorado;
    if (puntaje >= 15 && roll < 0.2) return TipoItem.cebolla;
    if (puntaje >= 10 && roll < 0.08) return TipoItem.dorado;
    return TipoItem.completo;
  }

  void _spawnItem() {
    final tipo = _tipoAleatorio();
    final x = _random.nextDouble() * (areaAncho - 60);
    // Base speed: ~50 pixels per second, scaling up
    final velocidadBase = 50.0 + (puntaje * 1.6).clamp(0, 80);
    setState(() {
      items.add(_Item(
        id: DateTime.now().millisecondsSinceEpoch + _random.nextInt(1000),
        tipo: tipo,
        x: x,
        y: -10,
        velocidad: velocidadBase,
      ));
    });
  }

  void _moverItems(double dt) {
    setState(() {
      List<_Item> aEliminar = [];
      for (var item in items) {
        item.y += item.velocidad * dt;
        if (item.y > areaAlto) {
          aEliminar.add(item);
          if (item.tipo != TipoItem.cebolla) {
            vidas--;
            if (vidas <= 0) {
              _terminarJuego();
              return;
            }
          }
        }
      }
      items.removeWhere((i) => aEliminar.contains(i));
    });
  }

  void _tocarItem(_Item item) {
    if (pausado) return;
    HapticFeedback.selectionClick();
    setState(() {
      items.remove(item);
      switch (item.tipo) {
        case TipoItem.completo:
          puntaje++;
          monedasGanadas++;
          break;
        case TipoItem.dorado:
          puntaje += 3;
          monedasGanadas += 5;
          HapticFeedback.mediumImpact();
          break;
        case TipoItem.cebolla:
          vidas--;
          HapticFeedback.heavyImpact();
          if (vidas <= 0) {
            _terminarJuego();
            return;
          }
          break;
      }
      if (puntaje > mejorPuntaje) {
        mejorPuntaje = puntaje;
      }
    });
    if (item.tipo != TipoItem.cebolla) {
      GameData.agregarMonedas(item.tipo == TipoItem.dorado ? 5 : 1);
      _mostrarFloating(item.x, item.y, item.tipo == TipoItem.dorado ? '+5 🪙' : '+1 🪙');
    } else {
      _mostrarFloating(item.x, item.y, '-1 ❤️');
    }
  }

  void _mostrarFloating(double x, double y, String texto) {
    final ft = _FloatingText(x: x, y: y, texto: texto);
    setState(() => _floatingTexts.add(ft));
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _floatingTexts.remove(ft));
    });
  }

  void _terminarJuego({bool mostrarDialogo = true}) {
    _ticker.stop();
    _guardarMejorPuntaje();

    setState(() {
      jugando = false;
      pausado = false;
      items = [];
    });

    if (!mostrarDialogo) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¡Fin del juego!', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.cafe), textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌭', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            Text('Puntaje: $puntaje', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.rojo), textAlign: TextAlign.center),
            Text('Mejor: $mejorPuntaje', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.mostaza), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: AppColors.crema, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text('+$monedasGanadas monedas', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.mostaza)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () { Navigator.pop(context); },
                  child: const Text('Salir', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w800)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () { Navigator.pop(context); _iniciarJuego(); },
                  child: const Text('Jugar de nuevo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13), textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
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
              const Text('🎮', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: const LinearProgressIndicator(minHeight: 4, color: AppColors.amarillo, backgroundColor: AppColors.crema),
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
            titulo: '🎮 Mini Juegos',
            gradiente: const [AppColors.amarillo, AppColors.naranja],
            accionDerecha: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (jugando) ...[
                  GestureDetector(
                    onTap: _pausarJuego,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      child: const Icon(Icons.pause, color: Colors.white, size: 20),
                    ),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(99)),
                  child: Text('🏆 $mejorPuntaje', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ],
            ),
          ),

          if (!jugando) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌭', style: TextStyle(fontSize: 80)),
                    const SizedBox(height: 16),
                    const Text('Atrapa el Completo', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.cafe)),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Toca los completos 🌭 y las estrellas ⭐\n¡Cuidado con las cebollas 🧅!\nCada acierto te da monedas 🪙',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.mostaza, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Mejor puntaje: $mejorPuntaje', style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _iniciarJuego,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.rojo, AppColors.naranja]),
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: [BoxShadow(color: AppColors.rojo.withAlpha(102), blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        child: const Text('¡Jugar!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: List.generate(3, (i) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(i < vidas ? '❤️' : '🖤', style: const TextStyle(fontSize: 22)),
                  ))),
                  Row(
                    children: [
                      CoinBadge(monedas: monedasGanadas, backgroundColor: AppColors.amarillo.withAlpha(77)),
                      const SizedBox(width: 12),
                      Text('$puntaje pts', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.cafe)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  areaAncho = constraints.maxWidth;
                  areaAlto = constraints.maxHeight;
                  return Stack(
                    children: [
                      Container(decoration: BoxDecoration(color: AppColors.crema, borderRadius: BorderRadius.circular(20))),
                      ...items.map((item) => Positioned(
                        left: item.x,
                        top: item.y,
                        child: GestureDetector(
                          onTap: () => _tocarItem(item),
                          child: Text(item.emoji, style: TextStyle(fontSize: item.size)),
                        ),
                      )),
                      ..._floatingTexts.map((ft) => TweenAnimationBuilder<double>(
                        key: ValueKey(ft.hashCode),
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, val, child) => Positioned(
                          left: ft.x,
                          top: ft.y - (val * 40),
                          child: Opacity(
                            opacity: 1.0 - val,
                            child: Text(ft.texto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.cafe)),
                          ),
                        ),
                      )),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _FloatingText {
  final double x;
  final double y;
  final String texto;
  _FloatingText({required this.x, required this.y, required this.texto});
}
