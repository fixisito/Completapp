import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double hambre = 80;
  double felicidad = 80;
  int nivel = 1;
  int ultimosCompletos = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimaVez = prefs.getInt('pet_timestamp') ?? 0;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final segundosPasados = ((ahora - ultimaVez) / 1000).floor();

    setState(() {
      hambre = ((prefs.getDouble('pet_hambre') ?? 80) - (segundosPasados / 30) * 3).clamp(0, 100);
      felicidad = ((prefs.getDouble('pet_felicidad') ?? 80) - (segundosPasados / 30) * 2).clamp(0, 100);
      nivel = prefs.getInt('pet_nivel') ?? 1;
      ultimosCompletos = prefs.getInt('ultimos_completos') ?? 0;
    });
  }

  String get _estadoAnimo {
    final min = hambre < felicidad ? hambre : felicidad;
    if (min > 70) return '😄';
    if (min > 40) return '😐';
    return '😢';
  }

  String get _mensajePet {
    final min = hambre < felicidad ? hambre : felicidad;
    if (min > 70) return '¡Estoy feliz y satisfecho!';
    if (min > 40) return 'Podría comer algo...';
    return '¡Tengo hambre, aliméntame!';
  }

  Color _colorBarra(double valor) {
    if (valor > 60) return AppColors.verde;
    if (valor > 30) return AppColors.amarillo;
    return AppColors.rojo;
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
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.rojo, AppColors.naranja],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CompletApp 🌭',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  DateTime.now().hour < 12
                      ? '¡Buenos días!'
                      : DateTime.now().hour < 20
                      ? '¡Buenas tardes!'
                      : '¡Buenas noches!',
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // TARJETA PET
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFd0f0d8), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.verde.withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // PET EMOJI
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text('🌭', style: TextStyle(fontSize: 64)),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Text(_estadoAnimo, style: const TextStyle(fontSize: 20)),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Mi Completito',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.cafe),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.verde,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text('Nv. $nivel',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(_mensajePet,
                                style: const TextStyle(fontSize: 12, color: AppColors.mostaza, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),
                              _miniStatBarra('🍞', hambre, _colorBarra(hambre)),
                              const SizedBox(height: 6),
                              _miniStatBarra('😄', felicidad, _colorBarra(felicidad)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ALERTA SI EL PET TIENE HAMBRE
                  if (hambre < 30)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFfff3cd),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.amarillo, width: 2),
                      ),
                      child: const Row(
                        children: [
                          Text('⚠️', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text('¡Tu completito tiene hambre! Ve a alimentarlo.',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mostaza),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ACCESOS RAPIDOS
                  const Text('¿Qué hacemos?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.cafe),
                  ),
                  const SizedBox(height: 14),

                  // CARD CALCULADORA
                  _MenuCard(
                    emoji: '🧮',
                    titulo: 'Calculadora',
                    subtitulo: ultimosCompletos > 0
                        ? 'Último cálculo: $ultimosCompletos completos'
                        : '¿Cuántos completos necesitas?',
                    gradiente: const [AppColors.rojo, Color(0xFFc0180c)],
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _MenuCard(
                          emoji: '🌭',
                          titulo: 'Mi Completo',
                          subtitulo: 'Nivel $nivel',
                          gradiente: const [AppColors.verde, Color(0xFF1d8a38)],
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuCard(
                          emoji: '🎮',
                          titulo: 'Mini Juegos',
                          subtitulo: 'Gana accesorios',
                          gradiente: const [AppColors.amarillo, Color(0xFFd4a500)],
                          onTap: () {},
                        ),
                      ),
                    ],
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

  Widget _miniStatBarra(String emoji, double valor, Color color) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: valor / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFf0f0f0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('${valor.toInt()}%',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.mostaza),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String emoji;
  final String titulo;
  final String subtitulo;
  final List<Color> gradiente;
  final VoidCallback onTap;

  const _MenuCard({
    required this.emoji,
    required this.titulo,
    required this.subtitulo,
    required this.gradiente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradiente,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradiente[0].withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            Text(subtitulo,
              style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}