import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../widgets/color_picker.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final bool isFloating;

  const NoteEditorScreen({super.key, this.note, this.isFloating = false});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Note _note;

  @override
  void initState() {
    super.initState();
    
    if (widget.note != null) {
      _note = widget.note!;
      _titleController = TextEditingController(text: _note.title);
      _contentController = TextEditingController(text: _note.content);
    } else {
      final now = DateTime.now();
      _note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: now,
        updatedAt: now,
      );
      _titleController = TextEditingController();
      _contentController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final storageService = await StorageService.getInstance();
    
    final updatedNote = _note.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      updatedAt: DateTime.now(),
    );

    await storageService.saveNote(updatedNote);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _updateColor(int color) {
    setState(() {
      _note = _note.copyWith(color: color);
    });
  }

  void _togglePin() {
    setState(() {
      _note = _note.copyWith(isPinned: !_note.isPinned);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(_note.color),
      appBar: AppBar(
        backgroundColor: Color(_note.color).withOpacity(0.9),
        elevation: 0,
        automaticallyImplyLeading: !widget.isFloating,
        leading: widget.isFloating
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Titulo da nota',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _note.isPinned ? Colors.black : Colors.black54,
            ),
            onPressed: _togglePin,
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black87),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.black.withOpacity(0.05),
            child: ColorPicker(
              selectedColor: _note.color,
              onColorSelected: _updateColor,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Escreva sua nota aqui...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
        ],
      ),
    );
  }
}