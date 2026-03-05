import 'dart:io';
import 'single_instance_service_interface.dart';
import '../utils/errors/single_instance_exceptions.dart';

/// Serviço para garantir que apenas uma instância do gestor principal esteja aberta
class SingleInstanceService implements SingleInstanceServiceInterface {
  static final SingleInstanceService _instance = SingleInstanceService._internal();
  factory SingleInstanceService() => _instance;
  SingleInstanceService._internal();

  File? _lockFile;
  bool _isLocked = false;

  @override
  /// Tenta obter o lock. Retorna true se conseguiu (é a primeira instância),
  /// false se já existe outra instância
  Future<bool> tryLock() async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return true; // No mobile, sempre permite
    }

    try {
      // Usar diretório temporário do sistema
      final tempDir = Directory.systemTemp;
      final lockPath = '${tempDir.path}/sticky_notes_manager.lock';
      _lockFile = File(lockPath);

      // Verificar se já existe um lock
      if (await _lockFile!.exists()) {
        try {
          // Tentar ler o PID do processo que criou o lock
          final content = await _lockFile!.readAsString();
          final pid = int.tryParse(content);
          
          if (pid != null) {
            // Verificar se o processo ainda está em execução
            if (await _isProcessRunning(pid)) {
              final error = LockAcquisitionException(
                'Já existe uma instância do gestor em execução (PID: $pid)',
              );
              print('SingleInstance: ${error.message}');
              return false;
            } else {
              // Processo morreu, podemos assumir o lock
              print('SingleInstance: Processo anterior ($pid) não está em execução, assumindo lock');
            }
          }
        } on FormatException catch (e) {
          final error = LockAcquisitionException(
            'Arquivo de lock corrompido',
            originalError: e,
          );
          print('SingleInstance: ${error.message}');
          // Lock corrompido, remover e continuar
          try {
            await _lockFile!.delete();
          } catch (_) {}
        } catch (e) {
          final error = LockAcquisitionException(
            'Erro ao verificar lock existente',
            originalError: e,
          );
          print('SingleInstance: ${error.message}');
          // Em caso de erro, tentamos continuar
        }
      }

      // Criar novo lock com PID atual
      await _lockFile!.writeAsString('$pid');
      _isLocked = true;
      
      print('SingleInstance: Lock obtido com sucesso (PID: $pid)');
      return true;
    } on FileSystemException catch (e) {
      final error = LockAcquisitionException(
        'Erro de sistema de arquivos ao obter lock',
        originalError: e,
      );
      print('SingleInstance: ${error.message}');
      return false;
    } catch (e) {
      final error = LockAcquisitionException(
        'Erro desconhecido ao obter lock',
        originalError: e,
      );
      print('SingleInstance: ${error.message}');
      return false;
    }
  }

  /// Verifica se um processo está em execução
  Future<bool> _isProcessRunning(int pid) async {
    try {
      if (Platform.isWindows) {
        // Windows: usar tasklist
        final result = await Process.run('tasklist', ['/FI', "PID eq $pid", '/NH']);
        if (result.exitCode != 0) {
          throw ProcessCheckException(
            'Falha ao executar tasklist',
            originalError: result.stderr,
          );
        }
        return result.stdout.toString().contains(pid.toString());
      } else {
        // Linux/Mac: usar ps
        final result = await Process.run('ps', ['-p', pid.toString()]);
        if (result.exitCode != 0) {
          throw ProcessCheckException(
            'Falha ao executar ps',
            originalError: result.stderr,
          );
        }
        return result.exitCode == 0;
      }
    } on ProcessException catch (e) {
      final error = ProcessCheckException(
        'Erro ao executar comando para verificar processo',
        originalError: e,
      );
      print('SingleInstance: ${error.message}');
      return false;
    } catch (e) {
      final error = ProcessCheckException(
        'Erro desconhecido ao verificar processo',
        originalError: e,
      );
      print('SingleInstance: ${error.message}');
      return false;
    }
  }

  @override
  /// Libera o lock quando o aplicativo fecha
  Future<void> release() async {
    if (_isLocked && _lockFile != null) {
      try {
        if (await _lockFile!.exists()) {
          await _lockFile!.delete();
          print('SingleInstance: Lock liberado');
        }
        _isLocked = false;
      } on FileSystemException catch (e) {
        final error = LockReleaseException(
          'Erro de sistema de arquivos ao liberar lock',
          originalError: e,
        );
        print('SingleInstance: ${error.message}');
        rethrow;
      } catch (e) {
        final error = LockReleaseException(
          'Erro desconhecido ao liberar lock',
          originalError: e,
        );
        print('SingleInstance: ${error.message}');
        rethrow;
      }
    }
  }
}