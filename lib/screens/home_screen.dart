import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../widgets/note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  List<Note> _notes = [];
  bool _isLoading = true;
  bool _hasExternalChanges = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _setupWindowListener();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    windowManager.removeListener(this);
    super.dispose();
  }

  void _setupWindowListener() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _checkForExternalChanges();
      }
    });
  }

  @override
  void onWindowFocus() {
    _checkForExternalChanges();
  }

  @override
  void onWindowEnterFullScreen() {}
  @override
  void onWindowLeaveFullScreen() {}
  @override
  void onWindowMaximize() {}
  @override
  void onWindowMinimize() {}
  @override
  void onWindowRestore() {}
  @override
  void onWindowResize() {}
  @override
  void onWindowMove() {}
  @override
  void onWindowEvent(String eventName) {}

  Future<void> _checkForExternalChanges() async {
    try {
      final storageService = await StorageService.getInstance();
      final currentNotes = await storageService.getAllNotes();
      
      if (_notes.length != currentNotes.length) {
        print('Número de notas mudou: ${_notes.length} -> ${currentNotes.length}');
        await _loadNotes();
        return;
      }
      
      for (final currentNote in currentNotes) {
        final existingNote = _notes.firstWhere(
          (n) => n.id == currentNote.id,
          orElse: () => currentNote,
        );
        
        if (existingNote.updatedAt != currentNote.updatedAt) {
          print('Nota atualizada: ${currentNote.title}');
          await _loadNotes();
          return;
        }
      }
    } catch (e) {
      print('Erro ao verificar alterações: $e');
    }
  }

  Future<void> _loadNotes() async {
    print('_loadNotes: A carregar notas...');
    setState(() { _isLoading = true; _hasExternalChanges = false; });
    
    try {
      final storageService = await StorageService.getInstance();
      final notes = await storageService.getAllNotes();
      
      // Corrigir notas com posições inválidas
      final fixedNotes = notes.map((note) {
        double posX = note.posX;
        double posY = note.posY;
        
        // Corrigir valores negativos ou muito grandes
        if (posX < 0 || posX > 2000) posX = 50;
        if (posY < 0 || posY > 1500) posY = 50;
        
        if (posX != note.posX || posY != note.posY) {
          return note.copyWith(posX: posX, posY: posY);
        }
        return note;
      }).toList();
      
      // Guardar notas corrigidas se necessário
      for (var i = 0; i < fixedNotes.length; i++) {
        if (fixedNotes[i].posX != notes[i].posX || fixedNotes[i].posY != notes[i].posY) {
          await storageService.saveNote(fixedNotes[i]);
        }
      }
      
      print('_loadNotes: Notas carregadas: ${fixedNotes.length}');
      for (var note in fixedNotes) {
        print('  - ${note.id}: ${note.title} (pos: ${note.posX}, ${note.posY})');
      }
      
      setState(() {
        _notes = fixedNotes..sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        _isLoading = false;
      });
      
      if (_hasExternalChanges && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados atualizados'), duration: Duration(seconds: 2), backgroundColor: Colors.blue),
        );
      }
    } catch (e) {
      print('Erro ao carregar notas: $e');
      setState(() { _isLoading = false; });
    }
  }

  void _showNoteEditor(Note note, {bool isNew = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteEditorSheet(
        note: note,
        isNew: isNew,
        onSave: (updatedNote) async {
          final storageService = await StorageService.getInstance();
          await storageService.saveNote(updatedNote);
          _loadNotes();
        },
        onDelete: isNew ? null : (noteId) async {
          final storageService = await StorageService.getInstance();
          await storageService.deleteNote(noteId);
          _loadNotes();
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _createNewNote() async {
    print('_createNewNote: A criar nota...');
    final now = DateTime.now();
    final note = Note(
      id: now.millisecondsSinceEpoch.toString(),
      title: 'Nota ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      createdAt: now,
      updatedAt: now,
    );

    final storageService = await StorageService.getInstance();
    await storageService.saveNote(note);
    print('_createNewNote: Nota guardada com ID: ${note.id}');
    _loadNotes();
    
    if (mounted) {
      _showNoteEditor(note, isNew: true);
    }
  }

  void _openAsFloating(Note note) async {
    print('_openAsFloating: A abrir nota ${note.id} como flutuante');
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      // Mobile: apenas mostrar o editor
      _showNoteEditor(note);
      return;
    }

    try {
      // Buscar a nota mais recente da lista
      final latestNote = _notes.firstWhere((n) => n.id == note.id, orElse: () => note);
      
      // Criar ficheiro temporário com os dados da nota
      final tempDir = Directory.systemTemp;
      final noteFilePath = '${tempDir.path}/note_${latestNote.id}.json';
      final noteFile = File(noteFilePath);
      
      final noteData = {
        'noteId': latestNote.id,
        'title': latestNote.title,
        'content': latestNote.content,
        'color': latestNote.color,
        'posX': latestNote.posX,
        'posY': latestNote.posY,
      };
      
      await noteFile.writeAsString(jsonEncode(noteData));
      print('Ficheiro criado: $noteFilePath');
      print('Posição da nota: ${latestNote.posX}, ${latestNote.posY}');
      
      // Obter o caminho do executável atual
      final exePath = Platform.resolvedExecutable;
      print('Executável: $exePath');
      
      // Executar nova instância com o ficheiro de nota
      final process = await Process.start(
        exePath,
        ['--note-file=$noteFilePath'],
        mode: ProcessStartMode.detached,
      );
      
      print('Processo iniciado com PID: ${process.pid}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nota "${note.title}" aberta como janela flutuante'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
      print('Nota flutuante aberta: $noteFilePath');
    } catch (e) {
      print('Erro ao abrir nota flutuante: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir nota flutuante: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNote(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Nota'),
        content: const Text('Tem a certeza que deseja eliminar esta nota?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storageService = await StorageService.getInstance();
      await storageService.deleteNote(id);
      _loadNotes();
    }
  }

  void _onNoteDrag(Note note, DragUpdateDetails details) {
    setState(() {
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index >= 0) {
        // Limitar posição para valores razoáveis
        double newPosX = (note.posX + details.delta.dx).clamp(0.0, 2000.0);
        double newPosY = (note.posY + details.delta.dy).clamp(0.0, 1500.0);
        
        _notes[index] = note.copyWith(
          posX: newPosX,
          posY: newPosY,
        );
      }
    });
  }

  Future<void> _onNoteDragEnd(Note note) async {
    // Buscar a nota atualizada da lista
    final updatedNote = _notes.firstWhere((n) => n.id == note.id);
    final storageService = await StorageService.getInstance();
    await storageService.saveNote(updatedNote);
    print('_onNoteDragEnd: Nota ${updatedNote.id} guardada com posição: ${updatedNote.posX}, ${updatedNote.posY}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('📝 Paff. And it\'s noted.', style: TextStyle(fontWeight: FontWeight.bold)),
            if (_hasExternalChanges) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: const Text('Atualizar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        backgroundColor: _hasExternalChanges ? Colors.orange[700] : Colors.amber[700],
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          if (_hasExternalChanges)
            IconButton(icon: const Icon(Icons.sync), onPressed: _loadNotes, tooltip: 'Atualizar'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadNotes, tooltip: 'Atualizar'),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty ? _buildEmptyState() : _buildNotesGrid(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewNote,
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova Nota'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Sem notas ainda', style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Toque no botão + para criar uma nota', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildNotesGrid() {
    if (_notes.isEmpty) {
      return const Center(child: Text('Sem notas'));
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return _buildNoteCard(note);
      },
    );
  }

  Widget _buildNoteCard(Note note) {
    return GestureDetector(
      onTap: () => _showNoteEditor(note),
      child: Container(
        decoration: BoxDecoration(
          color: Color(note.color),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8.0,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  if (note.isPinned)
                    const Icon(Icons.push_pin, size: 16, color: Colors.black54),
                  Expanded(
                    child: Text(
                      note.title.isNotEmpty ? note.title : 'Sem título',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Botão abrir como flutuante (só desktop)
                  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                    IconButton(
                      icon: const Icon(Icons.open_in_new, size: 18),
                      onPressed: () => _openAsFloating(note),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => _deleteNote(note.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Conteúdo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  note.content.isNotEmpty ? note.content : 'Clique para editar...',
                  style: TextStyle(
                    fontSize: 14,
                    color: note.content.isNotEmpty ? Colors.black87 : Colors.black38,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom Sheet Editor - Funciona como uma "janela flutuante" dentro da mesma app
class NoteEditorSheet extends StatefulWidget {
  final Note note;
  final bool isNew;
  final Function(Note) onSave;
  final Function(String)? onDelete;

  const NoteEditorSheet({super.key, required this.note, this.isNew = false, required this.onSave, this.onDelete});

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late int _color;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _color = widget.note.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedNote = widget.note.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      color: _color,
      updatedAt: DateTime.now(),
    );
    widget.onSave(updatedNote);
    setState(() { _hasChanges = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nota guardada!'), duration: Duration(seconds: 1), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Color(_color),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Barra de título
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Título da nota', border: InputBorder.none),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    onChanged: (_) => setState(() { _hasChanges = true; }),
                  ),
                ),
                if (_hasChanges)
                  IconButton(icon: const Icon(Icons.save, color: Colors.green), onPressed: _save, tooltip: 'Guardar'),
                if (!widget.isNew && widget.onDelete != null)
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => widget.onDelete!(widget.note.id), tooltip: 'Eliminar'),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (_hasChanges) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Guardar alterações?'),
                          content: const Text('Deseja guardar as alterações antes de fechar?'),
                          actions: [
                            TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('Não')),
                            TextButton(onPressed: () { _save(); Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('Sim')),
                          ],
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  tooltip: 'Fechar',
                ),
              ],
            ),
          ),
          // Seletor de cores
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black.withOpacity(0.05),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final color in [0xFFFFFF00, 0xFF90EE90, 0xFF87CEEB, 0xFFFFB6C1, 0xFFDDA0DD, 0xFFF0E68C, 0xFFFFA07A, 0xFF98FB98, 0xFFFFC0CB, 0xFFE6E6FA])
                    GestureDetector(
                      onTap: () { setState(() { _color = color; _hasChanges = true; }); },
                      child: Container(
                        width: 32, height: 32, margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: Border.all(color: _color == color ? Colors.black : Colors.transparent, width: 2),
                        ),
                        child: _color == color ? const Icon(Icons.check, size: 18) : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Conteúdo
          Expanded(
            child: TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: 'Escreva aqui...', border: InputBorder.none, contentPadding: EdgeInsets.all(16)),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (_) => setState(() { _hasChanges = true; }),
            ),
          ),
          // Botão guardar
          if (_hasChanges)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Nota'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}