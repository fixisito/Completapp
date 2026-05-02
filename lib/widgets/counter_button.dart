import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CounterButton extends StatelessWidget {
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int valor;
  final String? label;

  const CounterButton({
    super.key,
    required this.onIncrement,
    required this.onDecrement,
    required this.valor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFf5e8d0),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Icon(Icons.remove, size: 16, color: AppColors.cafe),
          ),
        ),
        SizedBox(
          width: 32,
          child: Center(
            child: Text(
              '$valor',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.cafe,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFf5e8d0),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Icon(Icons.add, size: 16, color: AppColors.cafe),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 8),
          Text(
            label!,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.mostaza,
            ),
          ),
        ],
      ],
    );
  }
}
