import 'dart:io';

/// Serviço para garantir que apenas uma instância do gestor principal esteja aberta
class SingleInstanceService {
  static final SingleInstanceService _instance = SingleInstanceService._internal();
  factory SingleInstanceService() => _instance;
  SingleInstanceService._internal();

  File? _lockFile;
  bool _isLocked = false;

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
              print('SingleInstance: Já existe uma instância do gestor em execução (PID: $pid)');
              return false;
            } else {
              // Processo morreu, podemos assumir o lock
              print('SingleInstance: Processo anterior ($pid) não está em execução, assumindo lock');
            }
          }
        } catch (e) {
          print('SingleInstance: Erro ao verificar lock existente: $e');
        }
      }

      // Criar novo lock com PID atual
      await _lockFile!.writeAsString('${pid}');
      _isLocked = true;
      
      print('SingleInstance: Lock obtido com sucesso (PID: ${pid})');
      return true;
    } catch (e) {
      print('SingleInstance: Erro ao obter lock: $e');
      return false;
    }
  }

  /// Verifica se um processo está em execução
  Future<bool> _isProcessRunning(int pid) async {
    try {
      if (Platform.isWindows) {
        // Windows: usar tasklist
        final result = await Process.run('tasklist', ['/FI', 'PID eq $pid', '/NH']);
        return result.exitCode == 0 && result.stdout.toString().contains(pid.toString());
      } else {
        // Linux/Mac: usar ps
        final result = await Process.run('ps', ['-p', pid.toString()]);
        return result.exitCode == 0;
      }
    } catch (e) {
      print('SingleInstance: Erro ao verificar processo: $e');
      return false;
    }
  }

  /// Libera o lock quando o aplicativo fecha
  Future<void> release() async {
    if (_isLocked && _lockFile != null) {
      try {
        if (await _lockFile!.exists()) {
          await _lockFile!.delete();
          print('SingleInstance: Lock liberado');
        }
      } catch (e) {
        print('SingleInstance: Erro ao liberar lock: $e');
      }
      _isLocked = false;
    }
  }
}