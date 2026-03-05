# Injeção de Dependências para Testes

Este documento descreve como a injeção de dependências foi implementada no aplicativo Paff para facilitar a criação de testes.

## Visão Geral

A injeção de dependências permite que as classes recebam suas dependências (como `StorageService`) através do construtor, em vez de criá-las internamente. Isso torna o código mais testável, pois podemos substituir as dependências reais por mocks durante os testes.

## Arquivos Modificados

### 1. `lib/injection.dart`
Arquivo central de configuração da injeção de dependências usando `GetIt`.

```dart
void setupTestLocator({StorageService? mockStorageService}) {
  resetLocator();
  
  if (mockStorageService != null) {
    locator.registerSingleton<StorageService>(mockStorageService);
  } else {
    locator.registerLazySingleton<StorageService>(() => StorageService());
  }
  
  locator.registerLazySingleton<NotesProvider>(
    () => NotesProvider(storageService: locator<StorageService>())
  );
}
```

### 2. `lib/providers/notes_provider.dart`
- Aceita `StorageService` opcional no construtor
- Usa o locator como fallback se nenhum serviço for fornecido

```dart
NotesProvider({StorageService? storageService})
    : _storageService = storageService ?? locator<StorageService>();
```

### 3. `lib/logic/home_screen_logic.dart`
- Aceita `StorageService` opcional no construtor
- Usa o locator como fallback se nenhum serviço for fornecido

```dart
HomeScreenLogic({StorageService? storageService})
    : _storageService = storageService ?? locator<StorageService>();
```

### 4. `lib/locator.dart`
Redireciona para o arquivo `injection.dart` para manter consistência.

## Como Escrever Testes

### 1. Configure o Mock

```dart
import 'package:mocktail/mocktail.dart';
import 'package:sticky_notes_app/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockStorageService mockStorageService;
  late NotesProvider notesProvider;

  setUp(() {
    mockStorageService = MockStorageService();
    notesProvider = NotesProvider(storageService: mockStorageService);
  });
}
```

### 2. Configure Comportamentos Esperados

```dart
when(() => mockStorageService.getNotes())
    .thenAnswer((_) async => testNotes.map((n) => n.toJson()).toList());
```

### 3. Execute e Verifique

```dart
await notesProvider.loadNotes();
expect(notesProvider.notes.length, 2);
verify(() => mockStorageService.getNotes()).called(1);
```

## Exemplos de Testes

Veja os arquivos de exemplo:
- `test/providers/notes_provider_test.dart` - Testes para o NotesProvider
- `test/logic/home_screen_logic_test.dart` - Testes para o HomeScreenLogic

## Benefícios

1. **Testabilidade**: Podemos testar cada classe isoladamente
2. **Controle**: Mockamos exatamente o que cada teste precisa
3. **Manutenção**: Fácil adicionar novas dependências no futuro
4. **Produtividade**: Reduz tempo de escrita de testes

## Dependências de Teste

Adicione ao `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
```

Execute `flutter pub get` após adicionar.

## Boas Práticas

1. Sempre injete dependências via construtor
2. Use o locator apenas como fallback para produção
3. Crie mocks específicos para cada teste
4. Limpe o estado entre testes com `setUp` e `tearDown`
5. Teste apenas uma unidade por vez (unit tests)