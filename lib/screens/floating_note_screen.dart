import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../services/storage_service.dart';
import '../widgets/color_picker.dart';
import '../models/note.dart';

class FloatingNoteScreen extends StatefulWidget {
  final String noteId;
  final String title;
  final String content;
  final int color;

  const FloatingNoteScreen({
    super.key,
    required this.noteId,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  State<FloatingNoteScreen> createState() => _FloatingNoteScreenState();
}

class _FloatingNoteScreenState extends State<FloatingNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late int _color;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _contentController = TextEditingController(text: widget.content);
    _color = widget.color;
    _setupWindow();
  }

  void _setupWindow() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.ensureInitialized();
      
      // Configurar janela como flutuante
      await windowManager.setSize(const Size(320, 420));
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setTitle(widget.title.isNotEmpty ? widget.title : 'Nota');
      await windowManager.show();
      await windowManager.focus();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote({bool showFeedback = false}) async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      final storageService = await StorageService.getInstance();
      
      // Buscar nota existente
      final notes = await storageService.getAllNotes();
      final note = notes.firstWhere(
        (n) => n.id == widget.noteId,
        orElse: () => Note(
          id: widget.noteId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final updatedNote = note.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        color: _color,
        updatedAt: DateTime.now(),
      );

      await storageService.saveNote(updatedNote);
      
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nota guardada!'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      setState(() {
        _hasChanges = false;
      });
    } catch (e) {
      print('Erro ao guardar nota: $e');
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao guardar'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _updateColor(int color) {
    setState(() {
      _color = color;
      _hasChanges = true;
    });
    _saveNote();
  }

  Future<void> _closeWindow() async {
    if (_hasChanges) {
      await _saveNote();
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.close();
    }
  }

  Future<void> _confirmClose() async {
    if (_hasChanges) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Guardar alterações?'),
          content: const Text('Deseja guardar as alterações antes de fechar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sim'),
            ),
          ],
        ),
      );
      
      if (result == true) {
        await _saveNote();
      }
    }
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(_color),
      body: Column(
        children: [
          // Barra de título
          Container(
            height: 40,
            color: Colors.black.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Título',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    onChanged: (_) {
                      setState(() {
                        _hasChanges = true;
                      });
                    },
                  ),
                ),
                // Botão Guardar
                if (_hasChanges)
                  IconButton(
                    icon: _isSaving 
                      ? const SizedBox(
                          width: 16, 
                          height: 16, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        )
                      : const Icon(Icons.save, size: 18, color: Colors.green),
                    onPressed: () => _saveNote(showFeedback: true),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                    tooltip: 'Guardar',
                  ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.minimize, size: 18),
                  onPressed: () async {
                    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
                      await windowManager.minimize();
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 16,
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _confirmClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 16,
                ),
              ],
            ),
          ),
          // Seletor de cor
          Container(
            padding: const EdgeInsets.all(4),
            color: Colors.black.withOpacity(0.05),
            child: ColorPicker(
              selectedColor: _color,
              onColorSelected: _updateColor,
            ),
          ),
          // Conteúdo da nota
          Expanded(
            child: TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'Escreva aqui...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (_) {
                setState(() {
                  _hasChanges = true;
                });
              },
            ),
          ),
          // Botão guardar na parte inferior
          if (_hasChanges)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.black.withOpacity(0.05),
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : () => _saveNote(showFeedback: true),
                icon: _isSaving 
                  ? const SizedBox(
                      width: 16, 
                      height: 16, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : const Icon(Icons.save),
                label: Text(_isSaving ? 'A guardar...' : 'Guardar Alterações'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}