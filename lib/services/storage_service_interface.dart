import '../models/note.dart';
import '../utils/errors/storage_exceptions.dart';

/// Interface para o serviço de armazenamento de notas.
/// 
/// Pode lançar as seguintes exceções:
/// - [StorageException] para erros gerais de armazenamento
/// - [FileAccessException] para erros de acesso a arquivos
/// - [JsonParseException] para erros de parsing JSON
/// - [DirectoryCreationException] para erros ao criar diretórios
abstract class StorageServiceInterface {
  /// Obtém todas as notas armazenadas.
  /// 
  /// Retorna uma lista vazia se não houver notas ou se o arquivo não existir.
  /// Pode lançar [StorageException] em caso de erro.
  Future<List<Note>> getAllNotes();
  
  /// Salva uma nota. Se a nota já existir, será atualizada.
  /// 
  /// Pode lançar [StorageException] em caso de erro.
  Future<void> saveNote(Note note);
  
  /// Deleta uma nota pelo seu ID.
  /// 
  /// Se a nota não existir, o método não faz nada (não lança exceção).
  /// Pode lançar [StorageException] em caso de erro.
  Future<void> deleteNote(String id);
}
