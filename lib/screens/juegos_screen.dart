import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import '../theme/colors.dart';

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
  Timer? _timer;
  final Random _random = Random();

  List<_Completo> completos = [];
  double areaAncho = 0;
  double areaAlto = 0;

  @override
  void initState() {
    super.initState();
    _cargarMejorPuntaje();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarMejorPuntaje() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mejorPuntaje = prefs.getInt('mejor_puntaje_atrapa') ?? 0;
    });
  }

  Future<void> _guardarMejorPuntaje() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mejor_puntaje_atrapa', mejorPuntaje);
  }

  Future<void> _darExpAlPet(int cantidad) async {
    final prefs = await SharedPreferences.getInstance();
    int exp = prefs.getInt('pet_exp') ?? 0;
    int nivel = prefs.getInt('pet_nivel') ?? 1;
    exp += cantidad;
    final expNecesaria = nivel * 50;
    if (exp >= expNecesaria) {
      exp -= expNecesaria;
      nivel++;
    }
    await prefs.setInt('pet_exp', exp);
    await prefs.setInt('pet_nivel', nivel);
  }

  Future<void> _bajarFelicidad() async {
    final prefs = await SharedPreferences.getInstance();
    double felicidad = prefs.getDouble('pet_felicidad') ?? 80;
    felicidad = (felicidad - 5).clamp(0, 100);
    await prefs.setDouble('pet_felicidad', felicidad);
  }

  void _iniciarJuego() {
    setState(() {
      jugando = true;
      puntaje = 0;
      vidas = 3;
      completos = [];
    });

    // Spawn de completos cada 1.2 segundos
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (!mounted) return;
      _spawnCompleto();
    });

    // Loop de movimiento cada 50ms
    Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted || !jugando) {
        t.cancel();
        return;
      }
      _moverCompletos();
    });
  }

  void _spawnCompleto() {
    if (areaAncho == 0) return;
    final x = _random.nextDouble() * (areaAncho - 60);
    setState(() {
      completos.add(_Completo(
        id: DateTime.now().millisecondsSinceEpoch,
        x: x,
        y: 0,
        velocidad: 2.5 + (puntaje * 0.1).clamp(0, 4),
      ));
    });
  }

  void _moverCompletos() {
    setState(() {
      List<_Completo> aEliminar = [];
      for (var c in completos) {
        c.y += c.velocidad;
        if (c.y > areaAlto) {
          aEliminar.add(c);
          vidas--;
          _bajarFelicidad();
          if (vidas <= 0) _terminarJuego();
        }
      }
      completos.removeWhere((c) => aEliminar.contains(c));
    });
  }

  void _atrapar(_Completo completo) {
    setState(() {
      completos.remove(completo);
      puntaje++;
      if (puntaje > mejorPuntaje) {
        mejorPuntaje = puntaje;
        _guardarMejorPuntaje();
      }
    });
    _darExpAlPet(5);
  }

  void _terminarJuego() {
    _timer?.cancel();
    setState(() {
      jugando = false;
      completos = [];
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¡Fin del juego!',
          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.cafe),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌭', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            Text('Puntaje: $puntaje',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.rojo),
              textAlign: TextAlign.center,
            ),
            Text('Mejor: $mejorPuntaje',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.mostaza),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text('+${puntaje * 5} XP para tu completito',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.verde),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rojo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.pop(context);
                _iniciarJuego();
              },
              child: const Text('Jugar de nuevo',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
              ),
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
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.amarillo, AppColors.naranja],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🎮 Mini Juegos',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('🏆 $mejorPuntaje',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          if (!jugando) ...[
            // PANTALLA DE INICIO
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌭', style: TextStyle(fontSize: 80)),
                    const SizedBox(height: 16),
                    const Text('Atrapa el Completo',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.cafe),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Toca los completos antes de que caigan.\nCada acierto da +5 XP a tu completito.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.mostaza, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Mejor puntaje: $mejorPuntaje',
                      style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _iniciarJuego,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.rojo, AppColors.naranja],
                          ),
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.rojo.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Text('¡Jugar!',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // HUD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (i) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        i < vidas ? '❤️' : '🖤',
                        style: const TextStyle(fontSize: 22),
                      ),
                    )),
                  ),
                  Text('$puntaje pts',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.cafe),
                  ),
                ],
              ),
            ),

            // AREA DE JUEGO
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  areaAncho = constraints.maxWidth;
                  areaAlto = constraints.maxHeight;
                  return Stack(
                    children: [
                      // Fondo
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.crema,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      // Completos
                      ...completos.map((c) => Positioned(
                        left: c.x,
                        top: c.y,
                        child: GestureDetector(
                          onTap: () => _atrapar(c),
                          child: const Text('🌭', style: TextStyle(fontSize: 48)),
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

class _Completo {
  final int id;
  final double x;
  double y;
  final double velocidad;

  _Completo({
    required this.id,
    required this.x,
    required this.y,
    required this.velocidad,
  });
}