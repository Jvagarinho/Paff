import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class StorageService {
  static const String _notesKey = 'sticky_notes';
  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Recarregar preferências do disco para garantir dados atualizados
  Future<void> _reload() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Note>> getAllNotes() async {
    try {
      // Sempre recarregar para obter dados atualizados de outros processos
      await _reload();
      
      if (_prefs == null) return [];
      
      final String? notesJson = _prefs!.getString(_notesKey);
      if (notesJson == null || notesJson.isEmpty) {
        return [];
      }

      final List<dynamic> notesList = jsonDecode(notesJson);
      final notes = notesList.map((json) => Note.fromJson(json)).toList();
      print('StorageService: Carregadas ${notes.length} notas');
      return notes;
    } catch (e) {
      print('Erro ao carregar notas: $e');
      return [];
    }
  }

  Future<void> saveNote(Note note) async {
    try {
      // Recarregar para obter estado atual
      await _reload();
      
      if (_prefs == null) return;
      
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
      await _reload();
      
      if (_prefs == null) return;
      
      final notes = await getAllNotes();
      notes.removeWhere((note) => note.id == id);
      await _saveNotesList(notes);
      print('StorageService: Nota eliminada - ID: $id');
    } catch (e) {
      print('Erro ao eliminar nota: $e');
    }
  }

  Future<void> saveAllNotes(List<Note> notes) async {
    await _reload();
    await _saveNotesList(notes);
  }

  Future<void> _saveNotesList(List<Note> notes) async {
    if (_prefs == null) return;
    
    final notesJson = jsonEncode(notes.map((note) => note.toJson()).toList());
    await _prefs!.setString(_notesKey, notesJson);
    
    // Forçar commit imediato
    await _prefs!.reload();
    
    print('StorageService: Lista de notas guardada - Total: ${notes.length} notas');
  }

  Future<void> clearAllNotes() async {
    await _reload();
    if (_prefs == null) return;
    await _prefs!.remove(_notesKey);
  }
}