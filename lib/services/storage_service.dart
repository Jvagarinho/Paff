import 'dart:convert';
import 'dart:io';
import '../models/note.dart';

class StorageService {
  static const String _fileName = 'notes.json';
  static StorageService? _instance;
  File? _file;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    final directory = _getNotesDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    _file = File('${directory.path}/$_fileName');
  }

  Directory _getNotesDirectory() {
    if (Platform.isWindows) {
      return Directory('${Platform.environment['APPDATA']}/Paff');
    } else if (Platform.isMacOS) {
      return Directory('${Platform.environment['HOME']}/Library/Application Support/Paff');
    } else {
      return Directory('${Platform.environment['HOME']}/.paff');
    }
  }

  Future<List<Note>> getAllNotes() async {
    try {
      if (_file == null || !await _file!.exists()) {
        return [];
      }

      final contents = await _file!.readAsString();
      if (contents.isEmpty) {
        return [];
      }

      final List<dynamic> notesList = jsonDecode(contents);
      return notesList.map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      print('getAllNotes ERRO: $e');
      return [];
    }
  }

  Future<void> saveNote(Note note) async {
    try {
      if (_file == null) return;
      
      // Ler notas existentes
      List<Note> notes;
      try {
        notes = await getAllNotes();
      } catch (e) {
        notes = [];
      }
      
      // Atualizar ou adicionar
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index >= 0) {
        notes[index] = note;
      } else {
        notes.add(note);
      }
      
      // Guardar
      final notesJson = jsonEncode(notes.map((n) => n.toJson()).toList());
      await _file!.writeAsString(notesJson);
    } catch (e) {
      print('saveNote ERRO: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      if (_file == null) return;
      
      final notes = await getAllNotes();
      notes.removeWhere((note) => note.id == id);
      
      final notesJson = jsonEncode(notes.map((n) => n.toJson()).toList());
      await _file!.writeAsString(notesJson);
    } catch (e) {
      print('deleteNote ERRO: $e');
    }
  }

  Future<void> saveAllNotes(List<Note> notes) async {
    try {
      if (_file == null) return;
      final notesJson = jsonEncode(notes.map((n) => n.toJson()).toList());
      await _file!.writeAsString(notesJson);
    } catch (e) {
      print('saveAllNotes ERRO: $e');
    }
  }

  Future<void> clearAllNotes() async {
    try {
      if (_file == null) return;
      if (await _file!.exists()) {
        await _file!.delete();
      }
    } catch (e) {}
  }
}
