import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/home_screen.dart';
import 'screens/floating_note_screen.dart';
import 'services/single_instance_service.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Argumentos recebidos: $args');
  
  // Verificar se é uma nota flutuante (pode ser passado como ficheiro)
  String? noteFilePath;
  for (final arg in args) {
    if (arg.startsWith('--note-file=')) {
      noteFilePath = arg.substring('--note-file='.length);
      print('Ficheiro de nota encontrado: $noteFilePath');
      break;
    }
  }
  
  // Se encontrou ficheiro, tentar ler - NOTAS FLUTUANTES NÃO USAM SINGLE INSTANCE
  if (noteFilePath != null) {
    try {
      final file = File(noteFilePath);
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final noteData = jsonDecode(jsonData);
        
        // Eliminar o ficheiro temporário
        await file.delete();
        
        print('A abrir nota flutuante: ${noteData['title']}');
        
        // Inicializar window manager para nota flutuante
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          await windowManager.ensureInitialized();
        }
        
        runApp(FloatingNoteApp(noteData: noteData));
        return;
      }
    } catch (e) {
      print('Erro ao ler ficheiro da nota: $e');
    }
  }
  
  // É a janela principal - verificar se já existe outra instância
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    final singleInstance = SingleInstanceService();
    final canRun = await singleInstance.tryLock();
    
    if (!canRun) {
      // Já existe uma instância do gestor em execução
      print('Gestor de notas já está em execução.');
      exit(0);
    }
    
    // Registrar liberação do lock quando o app fechar
    ProcessSignal.sigint.watch().listen((_) async {
      await singleInstance.release();
      exit(0);
    });
  }
  
  // Inicializar gestor
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(500, 700),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Paff. And it\'s noted.',
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const StickyNotesApp());
}

class StickyNotesApp extends StatelessWidget {
  const StickyNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paff. And it\'s noted.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class FloatingNoteApp extends StatelessWidget {
  final Map<String, dynamic> noteData;
  
  const FloatingNoteApp({super.key, required this.noteData});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: FloatingNoteScreen(
        noteId: noteData['noteId'] ?? '',
        title: noteData['title'] ?? '',
        content: noteData['content'] ?? '',
        color: noteData['color'] ?? 0xFFFFFF00,
        posX: (noteData['posX'] as num?)?.toDouble() ?? 100.0,
        posY: (noteData['posY'] as num?)?.toDouble() ?? 100.0,
      ),
    );
  }
}