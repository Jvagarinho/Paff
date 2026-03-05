import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sticky_notes_app/logic/home_screen_logic.dart';
import 'package:sticky_notes_app/models/note.dart';
import 'package:sticky_notes_app/services/storage_service.dart';

// Mock do StorageService para testes
class MockStorageService extends Mock implements StorageService {}

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

  group('HomeScreenLogic Tests', () {
    late MockStorageService mockStorageService;
    late HomeScreenLogic homeScreenLogic;

    setUp(() {
      mockStorageService = MockStorageService();
      homeScreenLogic = HomeScreenLogic(storageService: mockStorageService);
    });

    test('Deve iniciar com lista vazia e isLoading true', () {
      expect(homeScreenLogic.notes, isEmpty);
      expect(homeScreenLogic.isLoading, true);
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
      await homeScreenLogic.loadNotes();

      // Assert
      expect(homeScreenLogic.notes.length, 2);
      expect(homeScreenLogic.isLoading, false);
      verify(() => mockStorageService.getAllNotes()).called(1);
    });

    test('Deve corrigir posições inválidas das notas', () async {
      // Arrange
      final testNotes = [
        Note(
          id: '1',
          title: 'Teste',
          content: 'Conteúdo',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          posX: -100, // Inválido
          posY: 3000, // Inválido
        ),
      ];

      when(() => mockStorageService.getAllNotes())
          .thenAnswer((_) async => testNotes);

      when(() => mockStorageService.saveNote(any()))
          .thenAnswer((_) async {});

      // Act
      await homeScreenLogic.loadNotes();

      // Assert
      final loadedNote = homeScreenLogic.notes.first;
      expect(loadedNote.posX, 50); // Deve ser corrigido para 50
      expect(loadedNote.posY, 50); // Deve ser corrigido para 50
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

      when(() => mockStorageService.getAllNotes())
          .thenAnswer((_) async => [newNote]);

      // Act
      await homeScreenLogic.addNote(newNote);

      // Assert - verificar se saveNote foi chamado e loadNotes carregou a nota
      verify(() => mockStorageService.saveNote(newNote)).called(1);
      verify(() => mockStorageService.getAllNotes()).called(1);
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

      homeScreenLogic.addNoteForTest(existingNote); // Adicionar diretamente para teste

      final updatedNote = existingNote.copyWith(
        title: 'Atualizado',
        content: 'Conteúdo atualizado',
      );

      when(() => mockStorageService.saveNote(any()))
          .thenAnswer((_) async {});

      when(() => mockStorageService.getAllNotes())
          .thenAnswer((_) async => [updatedNote]);

      // Act
      await homeScreenLogic.updateNote(updatedNote);

      // Assert - verificar se saveNote foi chamado com a nota atualizada e loadNotes carregou
      verify(() => mockStorageService.saveNote(any())).called(1);
      verify(() => mockStorageService.getAllNotes()).called(1);
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

      homeScreenLogic.addNoteForTest(noteToRemove);

      when(() => mockStorageService.deleteNote(any()))
          .thenAnswer((_) async {});

      when(() => mockStorageService.getAllNotes())
          .thenAnswer((_) async => []);

      // Act
      await homeScreenLogic.deleteNote('1');

      // Assert - verificar se deleteNote foi chamado e loadNotes carregou lista vazia
      verify(() => mockStorageService.deleteNote('1')).called(1);
      verify(() => mockStorageService.getAllNotes()).called(1);
    });
  });
}