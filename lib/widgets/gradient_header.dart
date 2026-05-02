import 'package:flutter/material.dart';

class GradientHeader extends StatelessWidget {
  final String titulo;
  final List<Color> gradiente;
  final Widget? accionDerecha;
  final double borderRadius;

  const GradientHeader({
    super.key,
    required this.titulo,
    required this.gradiente,
    this.accionDerecha,
    this.borderRadius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradiente,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(borderRadius)),
      ),
      child: accionDerecha != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                accionDerecha!,
              ],
            )
          : Text(
              titulo,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
    );
  }
}
