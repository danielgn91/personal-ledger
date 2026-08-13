import 'package:flutter/material.dart';

Future<String?> showCreateFileDialog(
  BuildContext context,
) {
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Novo arquivo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome',
            hintText: 'Minhas finanças',
          ),
          onSubmitted: (value) {
            Navigator.pop(context, value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, controller.text);
            },
            child: const Text('Continuar'),
          ),
        ],
      );
    },
  );
}