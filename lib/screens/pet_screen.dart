import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../theme/colors.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  double hambre = 80;
  double felicidad = 80;
  int nivel = 1;
  int exp = 0;
  String accesorioActivo = '';
  Timer? _timer;

  final List<Map<String, dynamic>> accesorios = [
    {'emoji': '🎩', 'nombre': 'Galera',    'desbloqueado': true},
    {'emoji': '🕶️', 'nombre': 'Lentes',    'desbloqueado': true},
    {'emoji': '👑', 'nombre': 'Corona',    'desbloqueado': false, 'nivelReq': 3},
    {'emoji': '🤠', 'nombre': 'Cowboy',    'desbloqueado': false, 'nivelReq': 5},
    {'emoji': '🎓', 'nombre': 'Graduado',  'desbloqueado': false, 'nivelReq': 7},
    {'emoji': '🎃', 'nombre': 'Halloween', 'desbloqueado': false, 'nivelReq': 10},
  ];

  @override
  void initState() {
    super.initState();
    _cargarEstado();
    // Baja hambre y felicidad cada 30 segundos
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _bajarEstados();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimaVez = prefs.getInt('pet_timestamp') ?? 0;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final segundosPasados = ((ahora - ultimaVez) / 1000).floor();

    setState(() {
      hambre = (prefs.getDouble('pet_hambre') ?? 80)
          - (segundosPasados / 30) * 3;
      felicidad = (prefs.getDouble('pet_felicidad') ?? 80)
          - (segundosPasados / 30) * 2;
      hambre = hambre.clamp(0, 100);
      felicidad = felicidad.clamp(0, 100);
      nivel = prefs.getInt('pet_nivel') ?? 1;
      exp = prefs.getInt('pet_exp') ?? 0;
      accesorioActivo = prefs.getString('pet_accesorio') ?? '';
    });

    _actualizarAccesorios();
  }

  Future<void> _guardarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pet_hambre', hambre);
    await prefs.setDouble('pet_felicidad', felicidad);
    await prefs.setInt('pet_nivel', nivel);
    await prefs.setInt('pet_exp', exp);
    await prefs.setString('pet_accesorio', accesorioActivo);
    await prefs.setInt('pet_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  void _bajarEstados() {
    setState(() {
      hambre = (hambre - 3).clamp(0, 100);
      felicidad = (felicidad - 2).clamp(0, 100);
    });
    _guardarEstado();
  }

  void _alimentar() {
    setState(() {
      hambre = (hambre + 20).clamp(0, 100);
      felicidad = (felicidad + 5).clamp(0, 100);
      exp += 10;
      _subirNivel();
    });
    _guardarEstado();
    _mostrarToast('¡Completito comió! +20 hambre 🍞');
  }

  void _jugar() {
    setState(() {
      felicidad = (felicidad + 15).clamp(0, 100);
      hambre = (hambre - 5).clamp(0, 100);
      exp += 5;
      _subirNivel();
    });
    _guardarEstado();
    _mostrarToast('¡Completito jugó! +15 felicidad 🎉');
  }

  void _subirNivel() {
    final expNecesaria = nivel * 50;
    if (exp >= expNecesaria) {
      exp -= expNecesaria;
      nivel++;
      _actualizarAccesorios();
      _mostrarToast('🎉 ¡Subiste al nivel $nivel!');
    }
  }

  void _actualizarAccesorios() {
    for (var acc in accesorios) {
      if (!acc['desbloqueado'] && acc.containsKey('nivelReq')) {
        if (nivel >= acc['nivelReq']) {
          acc['desbloqueado'] = true;
        }
      }
    }
  }

  void _mostrarToast(String mensaje) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje,
            style: const TextStyle(fontWeight: FontWeight.w700)),
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
    final min = hambre < felicidad ? hambre : felicidad;
    if (min > 70) return '😄';
    if (min > 40) return '😐';
    return '😢';
  }

  String get _expTexto {
    final expNecesaria = nivel * 50;
    return '$exp / $expNecesaria XP';
  }

  double get _expPorcentaje {
    final expNecesaria = nivel * 50;
    return (exp / expNecesaria).clamp(0, 1);
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
                colors: [AppColors.verde, Color(0xFF1d8a38)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🌭 Mi Completito',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('Nivel $nivel',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
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
                    onTap: _alimentar,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text('🌭',
                            style: TextStyle(
                              fontSize: 100,
                              shadows: [Shadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                          ),
                          if (accesorioActivo.isNotEmpty)
                            Positioned(
                              top: 0,
                              child: Text(accesorioActivo, style: const TextStyle(fontSize: 40)),
                            ),
                          Positioned(
                            bottom: 0,
                            child: Text(_estadoAnimo, style: const TextStyle(fontSize: 28)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Text('Toca para alimentar',
                    style: TextStyle(fontSize: 12, color: AppColors.mostaza, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 20),

                  // STATS
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFd0f0d8), width: 2),
                    ),
                    child: Column(
                      children: [
                        _statBarra('🍞 Hambre', hambre, _colorBarra(hambre)),
                        const SizedBox(height: 12),
                        _statBarra('😄 Felicidad', felicidad, _colorBarra(felicidad)),
                        const SizedBox(height: 12),
                        _statBarra('⭐ Experiencia', _expPorcentaje * 100, AppColors.amarillo,
                            etiqueta: _expTexto),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ACCIONES
                  Row(
                    children: [
                      Expanded(
                        child: _botonAccion(
                          emoji: '🍞',
                          label: 'Alimentar',
                          color: AppColors.naranja,
                          onTap: _alimentar,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _botonAccion(
                          emoji: '🎾',
                          label: 'Jugar',
                          color: AppColors.verde,
                          onTap: _jugar,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ACCESORIOS
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('🎽 Accesorios',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.cafe),
                    ),
                  ),
                  const SizedBox(height: 10),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: accesorios.length,
                    itemBuilder: (_, i) {
                      final acc = accesorios[i];
                      final desbloqueado = acc['desbloqueado'] as bool;
                      final equipado = accesorioActivo == acc['emoji'];

                      return GestureDetector(
                        onTap: desbloqueado
                            ? () {
                          setState(() {
                            accesorioActivo = equipado ? '' : acc['emoji'];
                          });
                          _guardarEstado();
                        }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: equipado
                                ? const Color(0xFFe8f8ec)
                                : desbloqueado ? Colors.white : const Color(0xFFf5f5f5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: equipado ? AppColors.verde : const Color(0xFFe0e0e0),
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(acc['emoji'],
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: desbloqueado ? null : const Color(0xFFcccccc),
                                    ),
                                  ),
                                  Text(acc['nombre'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: desbloqueado ? AppColors.cafe : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (!desbloqueado)
                                Positioned(
                                  top: 4, right: 4,
                                  child: Text('Nv.${acc['nivelReq']}',
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey),
                                  ),
                                ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.cafe),
            ),
            Text(etiqueta ?? '${valor.toInt()}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mostaza),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: valor / 100,
            minHeight: 12,
            backgroundColor: const Color(0xFFf0f0f0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _botonAccion({
    required String emoji,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}