import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

Future<bool> showParentalGate(BuildContext context) async {
  final rng = Random();
  final a = rng.nextInt(18) + 2;
  final b = rng.nextInt(18) + 2;
  final answer = a + b;
  final controller = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Ask a Parent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('What is $a + $b ?', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Enter answer'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.backgroundDark,
            ),
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              Navigator.pop(context, value == answer);
            },
            child: const Text('Unlock'),
          ),
        ],
      );
    },
  );

  return result == true;
}
