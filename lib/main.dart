import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/calculadora_screen.dart';
import 'screens/pet_screen.dart';
import 'screens/juegos_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CompletApp());
}

class CompletApp extends StatelessWidget {
  const CompletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CompletApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainNav(),
    );
  }
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _paginaActual = 0;

  void _cambiarTab(int index) {
    setState(() => _paginaActual = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pantallas = [
      HomeScreen(onTabChange: _cambiarTab),
      const CalculadoraScreen(),
      const PetScreen(),
      const JuegosScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _paginaActual,
        children: pantallas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: _cambiarTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFE8281A),
        unselectedItemColor: const Color(0xFF5C3317),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate_rounded), label: 'Calcular'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Mi Completo'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports_rounded), label: 'Juegos'),
        ],
      ),
    );
  }
}