import 'package:flutter/material.dart';
import '../theme/colors.dart';

class JuegosScreen extends StatelessWidget {
  const JuegosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('🎮', style: TextStyle(fontSize: 80)),
            SizedBox(height: 16),
            Text(
              'Mini Juegos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.cafe,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Próximamente 👀',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mostaza,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}