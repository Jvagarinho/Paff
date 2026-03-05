import 'dart:convert';
import 'dart:io';
import '../models/note.dart';
import 'storage_service_interface.dart';
import '../utils/errors/storage_exceptions.dart';

class StorageService implements StorageServiceInterface {
  static const String _fileName = 'notes.json';
  final Directory _directory;
  File? _file;
  final bool _debugMode;

  StorageService({Directory? directory, bool debugMode = false})
      : _directory = directory ?? _getDefaultDirectory(),
        _debugMode = debugMode {
    // Initialize immediately when constructed
    _init();
  }

  static Directory _getDefaultDirectory() {
    if (Platform.isWindows) {
      return Directory('${Platform.environment['APPDATA']}/Paff');
    } else if (Platform.isMacOS) {
      return Directory('${Platform.environment['HOME']}/Library/Application Support/Paff');
    } else {
      return Directory('${Platform.environment['HOME']}/.paff');
    }
  }

  static StorageService? _instance;
  StorageService._(this._directory, [this._debugMode = false]);

  static Future<StorageService> getInstance({bool debugMode = false}) async {
    if (_instance == null) {
      final directory = _getDefaultDirectory();
      _instance = StorageService._(directory, debugMode);
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    try {
      if (!await _directory.exists()) {
        await _directory.create(recursive: true);
        _log('Diretório criado: ${_directory.path}');
      }
      _file = File('${_directory.path}/$_fileName');
      _log('StorageService inicializado com sucesso');
    } catch (e) {
      final error = DirectoryCreationException(
        'Falha ao inicializar diretório de armazenamento',
        originalError: e,
      );
      _log(error.toString());
      rethrow;
    }
  }

  void _log(String message) {
    if (_debugMode) {
      print('StorageService: $message');
    }
  }

  @override
  Future<List<Note>> getAllNotes() async {
    try {
      _log('Obtendo todas as notas');
      
      if (_file == null) {
        throw FileAccessException('StorageService não inicializado corretamente');
      }
      
      if (!await _file!.exists()) {
        _log('Arquivo não existe, retornando lista vazia');
        return [];
      }

      final contents = await _file!.readAsString();
      if (contents.isEmpty) {
        _log('Arquivo vazio, retornando lista vazia');
        return [];
      }

      try {
        final List<dynamic> notesList = jsonDecode(contents);
        final notes = notesList.map((json) => Note.fromJson(json)).toList();
        _log('${notes.length} notas carregadas com sucesso');
        return notes;
      } on FormatException catch (e) {
        throw JsonParseException(
          'Formato JSON inválido no arquivo de notas',
          originalError: e,
        );
      } catch (e) {
        throw JsonParseException(
          'Erro ao parsear JSON das notas',
          originalError: e,
        );
      }
    } catch (e) {
      if (e is StorageException) {
        _log('Erro ao obter notas: ${e.message}');
        rethrow;
      }
      final error = FileAccessException(
        'Erro desconhecido ao obter notas',
        originalError: e,
      );
      _log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> saveNote(Note note) async {
    try {
      _log('Salvando nota: ${note.id}');
      
      if (_file == null) {
        throw FileAccessException('StorageService não inicializado corretamente');
      }

      // Ler notas existentes
      List<Note> notes;
      try {
        notes = await getAllNotes();
      } on StorageException catch (e) {
        _log('Erro ao ler notas existentes: ${e.message}, iniciando com lista vazia');
        notes = [];
      }

      // Atualizar ou adicionar
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index >= 0) {
        notes[index] = note;
        _log('Nota ${note.id} atualizada');
      } else {
        notes.add(note);
        _log('Nota ${note.id} adicionada');
      }
      
      // Guardar
      final notesJson = jsonEncode(notes.map((n) => n.toJson()).toList());
      await _file!.writeAsString(notesJson);
      _log('Nota salva com sucesso');
    } catch (e) {
      if (e is StorageException) {
        _log('Erro ao salvar nota: ${e.message}');
        rethrow;
      }
      final error = FileAccessException(
        'Erro desconhecido ao salvar nota',
        originalError: e,
      );
      _log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      _log('Deletando nota: $id');
      
      if (_file == null) {
        throw FileAccessException('StorageService não inicializado corretamente');
      }

      final notes = await getAllNotes();
      final initialLength = notes.length;
      
      notes.removeWhere((note) => note.id == id);
      
      if (notes.length == initialLength) {
        _log('Nota $id não encontrada para exclusão');
        return;
      }
      
      final notesJson = jsonEncode(notes.map((n) => n.toJson()).toList());
      await _file!.writeAsString(notesJson);
      _log('Nota $id deletada com sucesso');
    } catch (e) {
      if (e is StorageException) {
        _log('Erro ao deletar nota: ${e.message}');
        rethrow;
      }
      final error = FileAccessException(
        'Erro desconhecido ao deletar nota',
        originalError: e,
      );
      _log(error.toString());
      rethrow;
    }
  }

  Future<void> saveAllNotes(List<Note> notes) async {
    try {
      _log('Salvando ${notes.length} notas em lote');
      
      if (_file == null) {
        throw FileAccessException('StorageService não inicializado corretamente');
      }
      
      final notesJson = jsonEncode(notes.map((n) => n.toJson()).toList());
      await _file!.writeAsString(notesJson);
      _log('Notas salvas em lote com sucesso');
    } catch (e) {
      if (e is StorageException) {
        _log('Erro ao salvar notas em lote: ${e.message}');
        rethrow;
      }
      final error = FileAccessException(
        'Erro desconhecido ao salvar notas em lote',
        originalError: e,
      );
      _log(error.toString());
      rethrow;
    }
  }

  Future<void> clearAllNotes() async {
    try {
      _log('Limpando todas as notas');
      
      if (_file == null) {
        throw FileAccessException('StorageService não inicializado corretamente');
      }
      
      if (await _file!.exists()) {
        await _file!.delete();
        _log('Arquivo de notas deletado com sucesso');
      } else {
        _log('Arquivo de notas não existe, nada a fazer');
      }
    } catch (e) {
      if (e is StorageException) {
        _log('Erro ao limpar notas: ${e.message}');
        rethrow;
      }
      final error = FileAccessException(
        'Erro desconhecido ao limpar notas',
        originalError: e,
      );
      _log(error.toString());
      rethrow;
    }
  }
}
