import 'package:flutter/material.dart';

import '../../domain/ledger.dart';

class LedgerList extends StatelessWidget {
  final List<Ledger> ledgers;
  final bool isLoading;
  final bool hasFile;
  final ValueChanged<Ledger>? onLedgerTap;

  const LedgerList({
    super.key,
    required this.ledgers,
    required this.isLoading,
    required this.hasFile,
    this.onLedgerTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!hasFile) {
      return const Center(
        child: Text(
          'Crie um novo arquivo ou abra um arquivo existente.',
        ),
      );
    }

    if (ledgers.isEmpty) {
      return const Center(
        child: Text(
          'Este arquivo ainda não possui ledgers.',
        ),
      );
    }

    return ListView.builder(
      itemCount: ledgers.length,
      itemBuilder: (context, index) {
        final ledger = ledgers[index];

        return ListTile(
          leading: const Icon(
            Icons.account_balance_wallet_outlined,
          ),
          title: Text(ledger.name),
          onTap: onLedgerTap == null
              ? null
              : () => onLedgerTap!(ledger),
        );
      },
    );
  }
}