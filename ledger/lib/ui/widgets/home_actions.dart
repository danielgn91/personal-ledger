import 'package:flutter/material.dart';

class HomeActions extends StatelessWidget {
  final bool hasFile;
  final VoidCallback onCreateFile;
  final VoidCallback onOpenFile;
  final VoidCallback onCreateLedger;

  const HomeActions({
    super.key,
    required this.hasFile,
    required this.onCreateFile,
    required this.onOpenFile,
    required this.onCreateLedger,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilledButton.icon(
          onPressed: onCreateFile,
          icon: const Icon(Icons.add),
          label: const Text('Novo arquivo'),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: onOpenFile,
          icon: const Icon(Icons.folder_open),
          label: const Text('Abrir arquivo'),
        ),
        if (hasFile) ...[
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onCreateLedger,
            icon: const Icon(Icons.add),
            label: const Text('Novo ledger'),
          ),
        ],
      ],
    );
  }
}