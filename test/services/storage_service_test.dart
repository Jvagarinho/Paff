import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sticky_notes_app/models/note.dart';
import 'package:sticky_notes_app/services/storage_service_interface.dart';

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

  group('StorageServiceInterface Tests', () {
    late MockStorageServiceInterface mockStorage;

    setUp(() {
      mockStorage = MockStorageServiceInterface();
    });

    test('Deve implementar getAllNotes retornando lista vazia', () async {
      when(() => mockStorage.getAllNotes()).thenAnswer((_) async => []);

      final result = await mockStorage.getAllNotes();

      expect(result, isEmpty);
      verify(() => mockStorage.getAllNotes()).called(1);
    });

    test('Deve implementar getAllNotes retornando notas', () async {
      final testNotes = [
        Note(
          id: '1',
          title: 'Test',
          content: 'Content',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockStorage.getAllNotes()).thenAnswer((_) async => testNotes);

      final result = await mockStorage.getAllNotes();

      expect(result.length, 1);
      expect(result.first.title, 'Test');
    });

    test('Deve implementar saveNote corretamente', () async {
      when(() => mockStorage.saveNote(any())).thenAnswer((_) async {});

      final note = Note(
        id: '1',
        title: 'Test',
        content: 'Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await mockStorage.saveNote(note);

      verify(() => mockStorage.saveNote(note)).called(1);
    });

    test('Deve implementar deleteNote corretamente', () async {
      when(() => mockStorage.deleteNote(any())).thenAnswer((_) async {});

      await mockStorage.deleteNote('1');

      verify(() => mockStorage.deleteNote('1')).called(1);
    });

    test('Deve permitir mock de exceções', () async {
      when(() => mockStorage.getAllNotes())
          .thenThrow(Exception('Erro de IO'));

      expect(
        () async => await mockStorage.getAllNotes(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
