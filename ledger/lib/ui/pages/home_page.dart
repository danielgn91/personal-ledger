import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/database/database.dart';
import '../../domain/ledger.dart' as domain;
import '../../services/ledger_file_service.dart';
import '../../services/ledger_service.dart';

import '../widgets/current_file_header.dart';
import '../widgets/ledger_list.dart';
import '../widgets/home_actions.dart';
import '../widgets/create_file_dialog.dart';
import '../widgets/create_ledger_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LedgerFileService _fileService = LedgerFileService();

  AppDatabase? _database;
  List<domain.Ledger> _ledgers = [];

  bool _isLoading = false;

  Future<void> _createFile() async {
    final name = await showCreateFileDialog(context);

    if (name == null || name.trim().isEmpty) {
      return;
    }

    final directory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Escolher pasta',
    );

    if (directory == null) {
      return;
    }

    final file = await _fileService.createFile(
      directory: Directory(directory),
      name: name.trim(),
    );

    if (file == null) {
      if (!mounted) return;

      await _showMessage(
        'Arquivo já existe',
        'Já existe um arquivo com esse nome nessa pasta.',
      );

      return;
    }

    await _openDatabase(file);
  }

  Future<void> _openFile() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Abrir arquivo de ledger',
      type: FileType.custom,
      allowedExtensions: ['db'],
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    final file = File(result.files.single.path!);

    final openedFile = await _fileService.openFile(file);

    if (openedFile == null) {
      return;
    }

    await _openDatabase(openedFile);
  }

  Future<void> _openDatabase(File file) async {
    await _database?.close();

    final database = AppDatabase(file);

    setState(() {
      _database = database;
      _ledgers = [];
      _isLoading = true;
    });

    final service = LedgerService(database);

    final ledgers = await service.findAll();

    if (!mounted) {
      return;
    }

    setState(() {
      _ledgers = ledgers;
      _isLoading = false;
    });
  }

  Future<void> _createLedger() async {
    final database = _database;

    if (database == null) {
      return;
    }

    final name = await showCreateLedgerDialog(context);

    if (name == null || name.trim().isEmpty) {
      return;
    }

    final service = LedgerService(database);

    final ledger = await service.create(name: name.trim());

    if (!mounted) {
      return;
    }

    setState(() {
      _ledgers = [
        ..._ledgers,
        ledger,
      ];
    });
  }

  void _openLedger(domain.Ledger ledger) {
    // TODO: abrir LedgerPage
  }

  Future<void> _showMessage(
    String title,
    String message,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurrentFileHeader(
              file: _fileService.currentFile,
            ),

            const SizedBox(height: 16),

            const Text(
              'Ledgers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: LedgerList(
                ledgers: _ledgers,
                isLoading: _isLoading,
                hasFile: _database != null,
                onLedgerTap: _openLedger,
              ),
            ),

            const SizedBox(height: 16),

            HomeActions(
              hasFile: _database != null,
              onCreateFile: _createFile,
              onOpenFile: _openFile,
              onCreateLedger: _createLedger,
            ),
          ],
        ),
      ),
    );
  }
}