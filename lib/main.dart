import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/calculadora_screen.dart';
import 'screens/pet_screen.dart';
import 'screens/juegos_screen.dart';
import 'services/game_data.dart';
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

class _MainNavState extends State<MainNav> with WidgetsBindingObserver {
  int _paginaActual = 0;
  bool _petHambriento = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _verificarHambre();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _verificarHambre();
  }

  Future<void> _verificarHambre() async {
    final stats = await GameData.getPetStats();
    if (!mounted) return;
    setState(() => _petHambriento = (stats['comida'] as double) < 30);
  }

  void _cambiarTab(int index) {
    setState(() => _paginaActual = index);
    _verificarHambre();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pantallas = [
      HomeScreen(onTabChange: _cambiarTab, isActive: _paginaActual == 0),
      const CalculadoraScreen(),
      PetScreen(isActive: _paginaActual == 2),
      JuegosScreen(isActive: _paginaActual == 3),
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
        selectedItemColor: AppColors.rojo,
        unselectedItemColor: AppColors.cafe,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 12,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          const BottomNavigationBarItem(icon: Icon(Icons.calculate_rounded), label: 'Calcular'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _petHambriento,
              backgroundColor: AppColors.rojo,
              smallSize: 8,
              child: const Icon(Icons.favorite_rounded),
            ),
            label: 'Mi Completo',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.sports_esports_rounded), label: 'Juegos'),
        ],
      ),
    );
  }
}