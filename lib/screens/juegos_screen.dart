import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import '../services/game_data.dart';
import '../theme/app_theme.dart';

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
  const JuegosScreen({super.key});
  @override
  State<JuegosScreen> createState() => _JuegosScreenState();
}

class _JuegosScreenState extends State<JuegosScreen> {
  bool jugando = false;
  int puntaje = 0;
  int mejorPuntaje = 0;
  int vidas = 3;
  int monedasGanadas = 0;
  Timer? _spawnTimer;
  Timer? _moveTimer;
  final Random _random = Random();

  List<_Item> items = [];
  double areaAncho = 0;
  double areaAlto = 0;

  @override
  void initState() {
    super.initState();
    _cargarMejorPuntaje();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _moveTimer?.cancel();
    super.dispose();
  }

  Future<void> _cargarMejorPuntaje() async {
    final stats = await GameData.getEstadisticas();
    if (!mounted) return;
    setState(() => mejorPuntaje = stats['mejorPuntaje'] ?? 0);
  }

  Future<void> _guardarMejorPuntaje() async {
    if (puntaje > mejorPuntaje) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('mejor_puntaje_atrapa', puntaje);
    }
  }

  void _iniciarJuego() {
    GameData.registrarPartida();
    setState(() {
      jugando = true;
      puntaje = 0;
      vidas = 3;
      monedasGanadas = 0;
      items = [];
    });

    _spawnTimer = Timer.periodic(Duration(milliseconds: _spawnInterval), (_) {
      if (!mounted) return;
      _spawnItem();
    });

    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted || !jugando) { t.cancel(); return; }
      _moverItems();
    });
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
    if (areaAncho == 0) return;
    final tipo = _tipoAleatorio();
    final x = _random.nextDouble() * (areaAncho - 60);
    if (!mounted) return;
    setState(() {
      items.add(_Item(
        id: DateTime.now().millisecondsSinceEpoch + _random.nextInt(1000),
        tipo: tipo,
        x: x,
        y: -10,
        velocidad: 2.5 + (puntaje * 0.08).clamp(0, 4),
      ));
    });
  }

  void _moverItems() {
    if (!mounted) return;
    setState(() {
      List<_Item> aEliminar = [];
      for (var item in items) {
        item.y += item.velocidad;
        if (item.y > areaAlto) {
          aEliminar.add(item);
          if (item.tipo != TipoItem.cebolla) {
            vidas--;
            if (vidas <= 0) _terminarJuego();
          }
        }
      }
      items.removeWhere((i) => aEliminar.contains(i));
    });
  }

  void _tocarItem(_Item item) {
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
          if (vidas <= 0) _terminarJuego();
          return;
      }
      if (puntaje > mejorPuntaje) {
        mejorPuntaje = puntaje;
      }
    });
    if (item.tipo != TipoItem.cebolla) {
      GameData.agregarMonedas(item.tipo == TipoItem.dorado ? 5 : 1);
    }
  }

  void _terminarJuego() {
    _spawnTimer?.cancel();
    _moveTimer?.cancel();
    _guardarMejorPuntaje();

    setState(() {
      jugando = false;
      items = [];
    });

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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () { Navigator.pop(context); _iniciarJuego(); },
              child: const Text('Jugar de nuevo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            ),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.amarillo, AppColors.naranja], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🎮 Mini Juegos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
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
                      Text('🪙 $monedasGanadas', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.mostaza)),
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