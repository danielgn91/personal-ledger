import 'dart:io';

import 'package:path/path.dart' as path;

class LedgerFileService {
  LedgerFileService();

  File? _currentFile;

  File? get currentFile => _currentFile;

  String? get currentFilePath => _currentFile?.path;

  Future<File?> createFile({
    required Directory directory,
    required String name,
  }) async {
    final fileName = name.endsWith('.db') ? name : '$name.db';

    final file = File(
      path.join(directory.path, fileName),
    );

    if (await file.exists()) {
      return null;
    }

    await file.create(recursive: true);

    _currentFile = file;

    return file;
  }

  Future<File?> openFile(File file) async {
    if (!await file.exists()) {
      return null;
    }

    _currentFile = file;

    return file;
  }

  void closeFile() {
    _currentFile = null;
  }
}