import 'dart:async';
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
  final double posX;
  final double posY;

  const FloatingNoteScreen({
    super.key,
    required this.noteId,
    required this.title,
    required this.content,
    required this.color,
    this.posX = 100.0,
    this.posY = 100.0,
  });

  @override
  State<FloatingNoteScreen> createState() => _FloatingNoteScreenState();
}

class _FloatingNoteScreenState extends State<FloatingNoteScreen> with WindowListener {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late int _color;
  late double _posX;
  late double _posY;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _contentController = TextEditingController(text: widget.content);
    _color = widget.color;
    _posX = widget.posX;
    _posY = widget.posY;
    _setupWindow();
    windowManager.addListener(this);
    
    // Verificar periodicamente se a nota ainda existe no storage
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }
        final storageService = await StorageService.getInstance();
        final notes = await storageService.getAllNotes();
        final exists = notes.any((n) => n.id == widget.noteId);
        if (!exists && mounted) {
          print('Nota eliminada no gestor, a fechar janela');
          await windowManager.close();
          timer.cancel();
        }
      });
    }
  }

  void _setupWindow() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.ensureInitialized();
      
      // Ocultar botões da janela (minimizar, maximizar, fechar)
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      
      // Garantir que a nota existe no armazenamento e obter posição guardada
      final storageService = await StorageService.getInstance();
      final notes = await storageService.getAllNotes();
      final existingNote = notes.where((n) => n.id == widget.noteId).firstOrNull;
      
      // Usar posição guardada se existir, senão usar a do widget
      double posX;
      double posY;
      
      if (existingNote != null) {
        posX = existingNote.posX;
        posY = existingNote.posY;
        print('_setupWindow: Usando posição guardada: $posX, $posY');
      } else {
        // Criar nota com posição inicial
        posX = widget.posX;
        posY = widget.posY;
        final newNote = Note(
          id: widget.noteId,
          title: widget.title,
          content: widget.content,
          color: widget.color,
          posX: posX,
          posY: posY,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await storageService.saveNote(newNote);
        print('_setupWindow: Nota criada com posição: $posX, $posY');
      }
      
      // Limitar posição para ficar dentro de valores razoáveis
      posX = posX.clamp(0.0, 2000.0);
      posY = posY.clamp(0.0, 1500.0);
      
      // Configurar janela como flutuante
      await windowManager.setSize(const Size(320, 420));
      await windowManager.setPosition(Offset(posX, posY));
      await windowManager.setTitle(widget.title.isNotEmpty ? widget.title : 'Nota');
      await windowManager.show();
      await windowManager.focus();
    }
  }

  @override
  void dispose() {
    _savePosition();
    windowManager.removeListener(this);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _savePosition() async {
    print('_savePosition: A guardar posição...');
    try {
      final position = await windowManager.getPosition();
      
      // Limitar posição para valores válidos
      final clampedX = position.dx.clamp(0.0, 2000.0);
      final clampedY = position.dy.clamp(0.0, 1500.0);
      print('_savePosition: Posição obtida: $clampedX, $clampedY');
      
      final storageService = await StorageService.getInstance();
      print('_savePosition: StorageService obtido');
      
      // Atualizar a nota diretamente
      final notes = await storageService.getAllNotes();
      print('_savePosition: Notas lidas: ${notes.length}');
      
      final index = notes.indexWhere((n) => n.id == widget.noteId);
      if (index >= 0) {
        notes[index] = notes[index].copyWith(posX: clampedX, posY: clampedY);
        print('_savePosition: Nota atualizada com posição: $clampedX, $clampedY');
      } else {
        print('_savePosition: Nota não encontrada, a criar nova');
        notes.add(Note(
          id: widget.noteId,
          title: widget.title,
          content: widget.content,
          color: widget.color,
          posX: clampedX,
          posY: clampedY,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
      
      await storageService.saveAllNotes(notes);
      print('_savePosition: Posição guardada com sucesso');
    } catch (e) {
      print('_savePosition ERRO: $e');
    }
  }

  Future<void> _ensureNoteExists(StorageService storageService) async {
    final notes = await storageService.getAllNotes();
    print('_ensureNoteExists: Notas no storage: ${notes.length}');
    final exists = notes.any((n) => n.id == widget.noteId);
    print('_ensureNoteExists: Nota ${widget.noteId} existe? $exists');
    
    if (!exists) {
      print('Nota não existe no armazenamento, a criar...');
      final newNote = Note(
        id: widget.noteId,
        title: widget.title,
        content: widget.content,
        color: widget.color,
        posX: widget.posX,
        posY: widget.posY,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await storageService.saveNote(newNote);
      print('Nota criada no armazenamento');
    } else {
      print('Nota já existe no armazenamento');
    }
  }

  @override
  void onWindowMove() {
    // Não guardar posição durante o movimento - apenas quando fechar
  }

  @override
  void onWindowResize() {
    // Não guardar durante o redimensionamento
  }

  Future<void> _saveNote({bool showFeedback = false}) async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      print('_saveNote: A guardar nota ${widget.noteId}');
      
      final storageService = await StorageService.getInstance();
      
      // Garantir que a nota existe no armazenamento
      await _ensureNoteExists(storageService);
      
      // Buscar nota existente
      final notes = await storageService.getAllNotes();
      print('_saveNote: Notas encontradas: ${notes.length}');
      
      final note = notes.firstWhere(
        (n) => n.id == widget.noteId,
        orElse: () {
          print('_saveNote: Nota não encontrada, a criar nova');
          return Note(
            id: widget.noteId,
            title: _titleController.text,
            content: _contentController.text,
            color: _color,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        },
      );

      final updatedNote = note.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        color: _color,
        updatedAt: DateTime.now(),
      );
      
      print('_saveNote: A guardar nota com título: ${updatedNote.title}');

      await storageService.saveNote(updatedNote);
      
      print('_saveNote: Nota guardada com sucesso');
      
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
    // Sempre guardar a posição antes de fechar
    await _savePosition();
    print('_confirmClose: Posição guardada');
    
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
          // Barra de título (arrastável)
          GestureDetector(
            onPanStart: (_) async {
              if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
                await windowManager.startDragging();
              }
            },
            child: Container(
              height: 30,
              color: Colors.black.withOpacity(0.05),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  // Zona do título - área arrastável visível
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black.withOpacity(0.1)),
                      ),
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
                  ),
                  // Espaço vazio arrastável entre título e botões
                  const Expanded(flex: 4, child: SizedBox()),
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
                const SizedBox(width: 8),
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
                const SizedBox(width: 8),
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