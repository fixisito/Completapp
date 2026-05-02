import 'package:flutter/material.dart';

class CoinBadge extends StatelessWidget {
  final int monedas;
  final Color? backgroundColor;

  const CoinBadge({
    super.key,
    required this.monedas,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white24,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$monedas',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
