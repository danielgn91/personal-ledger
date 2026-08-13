import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class CurrentFileHeader extends StatelessWidget {
  final File? file;

  const CurrentFileHeader({
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    if (file == null) {
      return const Text(
        'Nenhum arquivo aberto',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Tooltip(
      message: file!.path,
      child: Text(
        path.basename(file!.path),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}