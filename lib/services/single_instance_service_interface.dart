import '../utils/errors/single_instance_exceptions.dart';

/// Interface para o serviço de instância única (single instance).
/// 
/// Garante que apenas uma instância do aplicativo principal esteja em execução.
/// Pode lançar as seguintes exceções:
/// - [LockAcquisitionException] ao falhar ao obter o lock
/// - [LockReleaseException] ao falhar ao liberar o lock
/// - [ProcessCheckException] ao falhar ao verificar processos
abstract class SingleInstanceServiceInterface {
  /// Tenta obter o lock para garantir que esta é a única instância em execução.
  /// 
  /// Retorna true se conseguiu obter o lock (é a primeira instância),
  /// false se já existe outra instância em execução.
  /// Pode lançar [LockAcquisitionException] em caso de erro.
  Future<bool> tryLock();
  
  /// Libera o lock quando o aplicativo está fechando.
  /// 
  /// Pode lançar [LockReleaseException] em caso de erro.
  Future<void> release();
}
