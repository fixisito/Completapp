import 'package:flutter/material.dart';

class GradientHeader extends StatelessWidget {
  final String titulo;
  final List<Color> gradiente;
  final Widget? accionDerecha;
  final Widget? subtitulo;
  final double borderRadius;

  const GradientHeader({
    super.key,
    required this.titulo,
    required this.gradiente,
    this.accionDerecha,
    this.subtitulo,
    this.borderRadius = 28,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradiente,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(borderRadius)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              accionDerecha ?? const SizedBox.shrink(),
            ],
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: 4),
            subtitulo!,
          ],
        ],
      ),
    );
  }
}
