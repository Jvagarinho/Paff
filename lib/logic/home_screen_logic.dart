import 'dart:io';
import 'dart:convert';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../injection.dart';
import '../utils/errors/storage_exceptions.dart';

class HomeScreenLogic {
  final StorageService _storageService;
  List<Note> _notes = [];
  bool _isLoading = true;
  final bool _hasExternalChanges = false;

  HomeScreenLogic({StorageService? storageService})
      : _storageService = storageService ?? locator<StorageService>();

  List<Note> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;
  bool get hasExternalChanges => _hasExternalChanges;

  Future<void> loadNotes() async {
    print('_loadNotes: A carregar notas...');
    _isLoading = true;
    
    try {
      final notes = await _storageService.getAllNotes();
      
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
          try {
            await _storageService.saveNote(fixedNotes[i]);
          } catch (e) {
            print('Aviso: Falha ao salvar nota corrigida ${fixedNotes[i].id}: $e');
          }
        }
      }
      
      print('_loadNotes: Notas carregadas: ${fixedNotes.length}');
      for (var note in fixedNotes) {
        print('  - ${note.id}: ${note.title} (pos: ${note.posX}, ${note.posY})');
      }
      
      _notes = fixedNotes..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      _isLoading = false;
      
    } on StorageException catch (e) {
      print('Erro de armazenamento ao carregar notas: ${e.message}');
      _isLoading = false;
      throw Exception('Erro ao carregar notas: ${e.message}');
    } catch (e) {
      print('Erro desconhecido ao carregar notas: $e');
      _isLoading = false;
      throw Exception('Erro ao carregar notas: $e');
    }
  }

  // Método para testes - adiciona nota diretamente na lista
  void addNoteForTest(Note note) {
    _notes.add(note);
  }

  // Método para testes - limpa a lista de notas
  void clearNotesForTest() {
    _notes.clear();
  }

  Future<void> addNote(Note note) async {
    try {
      await _storageService.saveNote(note);
      await loadNotes();
    } on StorageException catch (e) {
      print('Erro de armazenamento ao adicionar nota: ${e.message}');
      rethrow;
    } catch (e) {
      print('Erro desconhecido ao adicionar nota: $e');
      throw Exception('Erro ao adicionar nota: $e');
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _storageService.saveNote(note);
      await loadNotes();
    } on StorageException catch (e) {
      print('Erro de armazenamento ao atualizar nota: ${e.message}');
      rethrow;
    } catch (e) {
      print('Erro desconhecido ao atualizar nota: $e');
      throw Exception('Erro ao atualizar nota: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _storageService.deleteNote(noteId);
      await loadNotes();
    } on StorageException catch (e) {
      print('Erro de armazenamento ao deletar nota: ${e.message}');
      rethrow;
    } catch (e) {
      print('Erro desconhecido ao deletar nota: $e');
      throw Exception('Erro ao deletar nota: $e');
    }
  }

  Future<void> openAsFloating(Note note) async {
    print('_openAsFloating: A abrir nota ${note.id} como flutuante');
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      // Mobile: apenas mostrar o editor
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
      
    } catch (e) {
      print('Erro ao abrir nota flutuante: $e');
      throw Exception('Erro ao abrir nota flutuante: $e');
    }
  }

  // Removido - lógica de verificação de mudanças externas deve estar no provider
}