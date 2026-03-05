import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sticky_notes_app/models/note.dart';
import 'package:sticky_notes_app/providers/notes_provider.dart';
import 'package:sticky_notes_app/services/storage_service_interface.dart';

/// Mock implementation of StorageServiceInterface for testing
class MockStorageServiceInterface extends Mock implements StorageServiceInterface {}

void main() {
  setUpAll(() {
    // Registrar fallback para Note (necessário para mocktail)
    registerFallbackValue(Note(
      id: '',
      title: '',
      content: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  });

  group('NotesProvider Tests', () {
    late MockStorageServiceInterface mockStorageService;
    late NotesProvider notesProvider;

    setUp(() {
      mockStorageService = MockStorageServiceInterface();
      notesProvider = NotesProvider(storageService: mockStorageService);
    });

    test('Deve iniciar com lista vazia e isLoading true', () {
      expect(notesProvider.notes, isEmpty);
      expect(notesProvider.isLoading, true);
    });

    test('Deve carregar notas corretamente', () async {
      // Arrange
      final testNotes = [
        Note(
          id: '1',
          title: 'Teste 1',
          content: 'Conteúdo 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Note(
          id: '2',
          title: 'Teste 2',
          content: 'Conteúdo 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockStorageService.getAllNotes())
          .thenAnswer((_) async => testNotes);

      // Act
      await notesProvider.loadNotes();

      // Assert
      expect(notesProvider.notes.length, 2);
      expect(notesProvider.isLoading, false);
      verify(() => mockStorageService.getAllNotes()).called(1);
    });

    test('Deve adicionar uma nova nota', () async {
      // Arrange
      final newNote = Note(
        id: '3',
        title: 'Nova Nota',
        content: 'Conteúdo novo',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockStorageService.saveNote(any()))
          .thenAnswer((_) async {});

      // Act
      await notesProvider.addNote(newNote);

      // Assert
      expect(notesProvider.notes.contains(newNote), true);
      verify(() => mockStorageService.saveNote(any())).called(1);
    });

    test('Deve atualizar uma nota existente', () async {
      // Arrange
      final existingNote = Note(
        id: '1',
        title: 'Original',
        content: 'Conteúdo original',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      notesProvider.notes.add(existingNote); // Adicionar diretamente para teste

      final updatedNote = existingNote.copyWith(
        title: 'Atualizado',
        content: 'Conteúdo atualizado',
      );

      when(() => mockStorageService.saveNote(any()))
          .thenAnswer((_) async {});

      // Act
      await notesProvider.updateNote(updatedNote);

      // Assert
      expect(notesProvider.notes.first.title, 'Atualizado');
      verify(() => mockStorageService.saveNote(any())).called(1);
    });

    test('Deve remover uma nota', () async {
      // Arrange
      final noteToRemove = Note(
        id: '1',
        title: 'Para remover',
        content: 'Conteúdo',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      notesProvider.notes.add(noteToRemove);

      when(() => mockStorageService.deleteNote(any()))
          .thenAnswer((_) async {});

      // Act
      await notesProvider.deleteNote('1');

      // Assert
      expect(notesProvider.notes.isEmpty, true);
      verify(() => mockStorageService.deleteNote('1')).called(1);
    });

    test('Deve marcar mudanças externas', () {
      // Act
      notesProvider.checkForExternalChanges();

      // Assert
      expect(notesProvider.hasExternalChanges, true);
    });

    test('Deve limpar mudanças externas', () {
      // Act
      notesProvider.clearExternalChanges();

      // Assert
      expect(notesProvider.hasExternalChanges, false);
    });

    test('Deve lidar com erro ao carregar notas', () async {
      // Arrange
      when(() => mockStorageService.getAllNotes())
          .thenThrow(Exception('Erro de leitura'));

      // Act & Assert
      expect(
        () async => await notesProvider.loadNotes(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Erro ao carregar notas'))),
      );
      expect(notesProvider.isLoading, false);
    });

    test('Deve lidar com erro ao adicionar nota', () async {
      // Arrange
      final newNote = Note(
        id: '3',
        title: 'Nova Nota',
        content: 'Conteúdo novo',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockStorageService.saveNote(any()))
          .thenThrow(Exception('Erro ao salvar'));

      // Act & Assert
      expect(
        () async => await notesProvider.addNote(newNote),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Erro ao adicionar nota'))),
      );
    });

    test('Deve lidar com erro ao atualizar nota inexistente', () async {
      // Arrange
      final nonExistentNote = Note(
        id: '999',
        title: 'Inexistente',
        content: 'Conteúdo',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockStorageService.saveNote(any()))
          .thenAnswer((_) async {});

      // Act
      await notesProvider.updateNote(nonExistentNote);

      // Assert - nota não deve ser adicionada à lista
      expect(notesProvider.notes.contains(nonExistentNote), false);
    });

    test('Deve notificar listeners quando estado muda', () {
      // Arrange
      final listener = MockVoidCallback();
      when(() => listener.call()).thenReturn(null);
      
      notesProvider.addListener(listener.call);

      // Act
      notesProvider.checkForExternalChanges();

      // Assert
      verify(() => listener.call()).called(1);
      
      notesProvider.removeListener(listener.call);
    });
  });
}

/// Mock para callback de listener
class MockVoidCallback extends Mock {
  void call();
}
