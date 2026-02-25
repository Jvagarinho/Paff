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
    print('StorageService: Ficheiro de notas em: ${_file!.path}');
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
      if (_file == null) return [];
      
      if (!await _file!.exists()) {
        print('StorageService: Ficheiro de notas não existe');
        return [];
      }

      final contents = await _file!.readAsString();
      if (contents.isEmpty) {
        print('StorageService: Ficheiro vazio');
        return [];
      }

      final List<dynamic> notesList = jsonDecode(contents);
      final notes = notesList.map((json) => Note.fromJson(json)).toList();
      print('StorageService: Carregadas ${notes.length} notas');
      for (var note in notes) {
        print('  - ID: ${note.id}, Título: ${note.title}');
      }
      return notes;
    } catch (e) {
      print('Erro ao carregar notas: $e');
      return [];
    }
  }

  Future<void> saveNote(Note note) async {
    try {
      if (_file == null) return;
      
      final notes = await getAllNotes();
      final index = notes.indexWhere((n) => n.id == note.id);
      
      if (index >= 0) {
        notes[index] = note;
        print('StorageService: Nota atualizada - ID: ${note.id}, Título: ${note.title}');
      } else {
        notes.add(note);
        print('StorageService: Nova nota adicionada - ID: ${note.id}, Título: ${note.title}');
      }
      
      await _saveNotesList(notes);
    } catch (e) {
      print('Erro ao guardar nota: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      if (_file == null) return;
      
      final notes = await getAllNotes();
      notes.removeWhere((note) => note.id == id);
      await _saveNotesList(notes);
      print('StorageService: Nota eliminada - ID: $id');
    } catch (e) {
      print('Erro ao eliminar nota: $e');
    }
  }

  Future<void> saveAllNotes(List<Note> notes) async {
    await _saveNotesList(notes);
  }

  Future<void> _saveNotesList(List<Note> notes) async {
    if (_file == null) return;
    
    final notesJson = jsonEncode(notes.map((note) => note.toJson()).toList());
    await _file!.writeAsString(notesJson, flush: true);
    
    // Verificar que foi escrito
    final verify = await _file!.readAsString();
    print('StorageService: Lista guardada e verificada - Total: ${notes.length} notas');
    print('StorageService: Conteúdo do ficheiro: ${verify.substring(0, verify.length > 100 ? 100 : verify.length)}...');
  }

  Future<void> clearAllNotes() async {
    if (_file == null) return;
    if (await _file!.exists()) {
      await _file!.delete();
    }
  }
}
