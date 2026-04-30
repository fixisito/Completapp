import 'package:flutter/material.dart';
import '../theme/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.rojo, AppColors.naranja],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CompletApp 🌭',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '¡Buenas! ¿Qué vamos a hacer hoy?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // CONTENIDO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Qué hacemos?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.cafe,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // CARD CALCULADORA
                  _MenuCard(
                    emoji: '🧮',
                    titulo: 'Calculadora',
                    subtitulo: '¿Cuántos completos necesitas?',
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
                          subtitulo: 'Tu Tamagotchi',
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
                ],
              ),
            ),
          ),
        ],
      ),
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
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              subtitulo,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}