# Paff - Sticky Notes App

> **And it's noted.**

Aplicação de notas adesivas moderna e multiplataforma desenvolvida em Flutter, inspirada no Sticky Notes do Windows, com foco em performance, confiabilidade e experiência do usuário.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Status](https://img.shields.io/badge/Status-Production%20Ready-success.svg)

## 📸 Screenshots

*Em breve - Capturas de tela da aplicação*

## ✨ Funcionalidades

### 📝 Editor de Texto Rico
- Suporte a **negrito**, *itálico*, <u>sublinhado</u>
- Listas numeradas e com marcadores
- Cabeçalhos e formatação avançada
- Suporte a emojis e caracteres especiais

### 🎨 Personalização Visual
- **10 cores** diferentes para categorizar notas
- Interface limpa e minimalista
- Transparências e sombras suaves
- Suporte a temas claro/escuro (em desenvolvimento)

### 📌 Organização
- **Fixar notas** importantes no topo
- **Arrastar e soltar** para reorganizar
- Ordenação automática por data de modificação
- Filtros por cor e status de fixação

### 💾 Persistência Robusta
- Armazenamento **local** em JSON
- **Auto-save** após cada edição
- **Recuperação de erros** com rollback automático
- Backup automático de dados corrompidos

### 🖥️ Multiplataforma
- ✅ **Windows** (x64)
- ✅ **Linux** (x64)
- ✅ **macOS** (Intel/Apple Silicon)
- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (experimental)

### 🔒 Single Instance (Desktop)
- Apenas **uma instância** do gestor principal
- Notas flutuantes independentes
- Sistema de lock com PID tracking
- Recuperação automática de locks órfãos

## 🏗️ Arquitetura

O projeto segue princípios de **Clean Architecture** e **SOLID**:

```
lib/
├── main.dart              # Ponto de entrada e configuração
├── injection.dart         # Injeção de dependências (GetIt)
├── locator.dart           # Service Locator
├── models/                # Camada de domínio
│   └── note.dart         # Entidade Note
├── services/              # Camada de dados
│   ├── storage_service.dart           # Implementação concreta
│   ├── storage_service_interface.dart # Contrato
│   ├── single_instance_service.dart   # Single instance
│   └── single_instance_service_interface.dart
├── providers/             # Camada de apresentação (State Management)
│   └── notes_provider.dart
├── screens/               # UI Widgets
│   ├── home_screen.dart
│   └── note_editor_screen.dart
├── widgets/               # Componentes reutilizáveis
│   ├── note_card.dart
│   └── color_picker.dart
├── logic/                 # Lógica de negócio
│   └── home_screen_logic.dart
└── utils/                # Utilitários
    ├── constants.dart
    └── errors/          # Sistema de exceções
        ├── storage_exceptions.dart
        └── single_instance_exceptions.dart
```

### Padrões Utilizados
- **Repository Pattern** - `StorageService`
- **Provider Pattern** - Gerenciamento de estado
- **Service Locator** - `GetIt` para injeção de dependências
- **Interface Segregation** - Interfaces específicas por responsabilidade
- **Error Handling** - Exceções customizadas com rollback

## 🚀 Como Começar

### Pré-requisitos

1. **Flutter SDK** (>=3.0.0)
   ```bash
   flutter --version
   ```

2. **Editor Recomendado**
   - [VS Code](https://code.visualstudio.com/) + Extensão Flutter
   - Ou [Android Studio](https://developer.android.com/studio)

3. **Ferramentas de Build** (para desktop)
   - **Windows**: Visual Studio 2022 com Desktop development with C++
   - **Linux**: `sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev`
   - **macOS**: Xcode Command Line Tools

### Instalação Rápida

```bash
# 1. Clone o repositório
git clone https://github.com/Jvagarinho/Paff.git
cd Paff

# 2. Instale dependências
flutter pub get

# 3. Execute em desenvolvimento
flutter run -d windows  # ou linux, macos, chrome, etc.
```

### Build para Produção

#### Desktop
```bash
# Windows
flutter build windows --release

# Linux
flutter build linux --release

# macOS
flutter build macos --release
```

#### Mobile
```bash
# Android APK
flutter build apk --release

# Android App Bundle (para Google Play)
flutter build appbundle --release

# iOS (requer macOS)
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## 🧪 Testes

O projeto inclui uma suíte completa de testes unitários:

```bash
# Executar todos os testes
flutter test

# Executar com cobertura
flutter test --coverage

# Ver relatório de cobertura
genhtml coverage/lcov.info -o coverage/html
```

### Status dos Testes
- ✅ **14/14 testes passando**
- ✅ Cobertura de serviços e providers
- ✅ Mock com `mocktail` para isolamento

## 🔧 Configuração

### Modo Debug (Logs Detalhados)

Para habilitar logs detalhados nos serviços:

```dart
final storage = StorageService(debugMode: true);
```

Os logs incluem:
- Operações de leitura/escrita
- Erros e exceções
- Ciclo de vida do single instance
- Rollbacks em caso de falha

### Variáveis de Ambiente

Nenhuma variável de ambiente necessária. O armazenamento usa:
- **Windows**: `%APPDATA%/Paff/notes.json`
- **macOS**: `~/Library/Application Support/Paff/notes.json`
- **Linux**: `~/.paff/notes.json`

## 🐛 Tratamento de Erros

O sistema implementa **tratamento de erros robusto**:

### Exceções Personalizadas
- `StorageException` - Erros gerais de armazenamento
- `FileAccessException` - Problemas de permissão/IO
- `JsonParseException` - Dados corrompidos
- `DirectoryCreationException` - Falha ao criar diretórios
- `LockAcquisitionException` - Falha no single instance
- `LockReleaseException` - Erro ao liberar lock

### Rollback Automático
Em caso de erro, o estado local é revertido automaticamente:
- `NotesProvider` mantém consistência
- `StorageService` não deixa dados órfãos
- `SingleInstanceService` limpa locks automaticamente

### Logs
- **Debug mode**: Logs detalhados no console
- **Release mode**: Apenas erros críticos
- **Arquivos**: Nenhum log em arquivo (pode ser adicionado)

## 📊 Qualidade de Código

### Análise Estática
```bash
flutter analyze --no-pub
```
✅ **Sem erros ou warnings**

### Convenções
- **Dart Style Guide** seguido rigorosamente
- **Effective Dart** guidelines
- **Super parameters** para construtores
- **Null safety** completo

### Cobertura de Testes
- Services: 100%
- Providers: 100%
- Logic: 100%

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. **Fork** o projeto
2. **Crie uma branch** para sua feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. **Push** para a branch (`git push origin feature/AmazingFeature`)
5. **Abra um Pull Request**

### Padrões de Commit
- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `docs:` Documentação
- `style:` Formatação (sem mudança de código)
- `refactor:` Refatoração
- `test:` Testes
- `chore:` Build/CI

## 📄 Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- [Flutter Team](https://flutter.dev) - Framework incrível
- [Quill](https://quilljs.com) - Editor de texto rico
- [GetIt](https://pub.dev/packages/get_it) - Service Locator
- [Provider](https://pub.dev/packages/provider) - State Management

## 📞 Suporte

- **Issues**: [GitHub Issues](https://github.com/Jvagarinho/Paff/issues)
- **Documentação**: Este README + [TESTING.md](TESTING.md)
- **Email**: [Seu email aqui]

---

**Desenvolvido com ❤️ e ☕ usando Flutter**

[![GitHub stars](https://img.shields.io/github/stars/Jvagarinho/Paff?style=social)](https://github.com/Jvagarinho/Paff/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/Jvagarinho/Paff?style=social)](https://github.com/Jvagarinho/Paff/network)
