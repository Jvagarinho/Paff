import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/storage_service_interface.dart';
import '../injection.dart';
import '../utils/errors/storage_exceptions.dart';

class NotesProvider extends ChangeNotifier {
  final StorageServiceInterface _storageService;
  List<Note> _notes = [];
  bool _isLoading = true;
  bool _hasExternalChanges = false;

  NotesProvider({StorageServiceInterface? storageService})
      : _storageService = storageService ?? locator<StorageServiceInterface>();

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  bool get hasExternalChanges => _hasExternalChanges;

  Future<void> loadNotes() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final notes = await _storageService.getAllNotes();
      _notes = notes;
      _isLoading = false;
      
      notifyListeners();
    } on StorageException catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Erro de armazenamento ao carregar notas: ${e.message}');
      rethrow;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Erro desconhecido ao carregar notas: $e');
      throw Exception('Erro ao carregar notas: $e');
    }
  }

  Future<void> addNote(Note note) async {
    try {
      _notes.add(note);
      notifyListeners();
      
      await _storageService.saveNote(note);
    } on StorageException catch (e) {
      // Reverter mudança local em caso de erro
      _notes.removeWhere((n) => n.id == note.id);
      notifyListeners();
      print('Erro de armazenamento ao adicionar nota: ${e.message}');
      rethrow;
    } catch (e) {
      // Reverter mudança local em caso de erro
      _notes.removeWhere((n) => n.id == note.id);
      notifyListeners();
      print('Erro desconhecido ao adicionar nota: $e');
      throw Exception('Erro ao adicionar nota: $e');
    }
  }

  Future<void> updateNote(Note note) async {
    int? index;
    Note? oldNote;
    
    try {
      index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        oldNote = _notes[index];
        _notes[index] = note;
        notifyListeners();
        
        await _storageService.saveNote(note);
      }
    } on StorageException catch (e) {
      // Reverter mudança local em caso de erro
      if (index != -1 && oldNote != null) {
        _notes[index!] = oldNote;
        notifyListeners();
      }
      print('Erro de armazenamento ao atualizar nota: ${e.message}');
      rethrow;
    } catch (e) {
      // Reverter mudança local em caso de erro
      if (index != -1 && oldNote != null) {
        _notes[index!] = oldNote;
        notifyListeners();
      }
      print('Erro desconhecido ao atualizar nota: $e');
      throw Exception('Erro ao atualizar nota: $e');
    }
  }

  /// Save a note - adds if new, updates if exists (upsert)
  Future<void> saveNote(Note note) async {
    int? index;
    Note? oldNote;
    
    try {
      index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        oldNote = _notes[index];
        _notes[index] = note;
      } else {
        _notes.add(note);
      }
      notifyListeners();
      
      await _storageService.saveNote(note);
    } on StorageException catch (e) {
      // Reverter mudança local em caso de erro
      if (index != -1 && oldNote != null) {
        _notes[index!] = oldNote;
      } else {
        _notes.removeWhere((n) => n.id == note.id);
      }
      notifyListeners();
      print('Erro de armazenamento ao salvar nota: ${e.message}');
      rethrow;
    } catch (e) {
      // Reverter mudança local em caso de erro
      if (index != -1 && oldNote != null) {
        _notes[index!] = oldNote;
      } else {
        _notes.removeWhere((n) => n.id == note.id);
      }
      notifyListeners();
      print('Erro desconhecido ao salvar nota: $e');
      throw Exception('Erro ao salvar nota: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    Note? noteToRemove;
    
    try {
      noteToRemove = _notes.firstWhere((n) => n.id == noteId);
      _notes.removeWhere((note) => note.id == noteId);
      notifyListeners();
      
      await _storageService.deleteNote(noteId);
    } on StorageException catch (e) {
      // Reverter mudança local em caso de erro
      if (noteToRemove != null) {
        _notes.add(noteToRemove);
        notifyListeners();
      }
      print('Erro de armazenamento ao deletar nota: ${e.message}');
      rethrow;
    } catch (e) {
      // Reverter mudança local em caso de erro
      if (noteToRemove != null) {
        _notes.add(noteToRemove);
        notifyListeners();
      }
      print('Erro desconhecido ao deletar nota: $e');
      throw Exception('Erro ao deletar nota: $e');
    }
  }

  void checkForExternalChanges() {
    // Lógica para verificar mudanças externas
    _hasExternalChanges = true;
    notifyListeners();
  }

  void clearExternalChanges() {
    _hasExternalChanges = false;
    notifyListeners();
  }

  // Método para testes - limpa a lista de notas
  void clearNotes() {
    _notes.clear();
    notifyListeners();
  }
}