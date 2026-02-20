# Sticky Notes App - Aplicação Multiplataforma

Uma aplicação de notas adesivas moderna e multiplataforma desenvolvida em Flutter, inspirada no Sticky Notes do Windows.

## ✨ Funcionalidades

- 📝 **Notas com Formatação Rica** - Editor completo com negrito, itálico, sublinhado, cores, listas, etc.
- 🎨 **Cores Personalizáveis** - 10 cores diferentes para organizar as suas notas
- 📌 **Fixar Notas** - Priorize as notas importantes
- 🖱️ **Arrastar e Soltar** - Organize as notas livremente no espaço de trabalho
- 💾 **Persistência Local** - As notas são guardadas automaticamente
- 🖥️ **Multiplataforma** - Funciona em Windows, Linux, macOS, iOS e Android

## 🚀 Como Começar

### Pré-requisitos

1. **Instalar Flutter SDK**
   - Siga as instruções em: https://docs.flutter.dev/get-started/install
   - Verifique a instalação: `flutter doctor`

2. **Editor de Código**
   - [VS Code](https://code.visualstudio.com/) (recomendado) com extensão Flutter
   - Ou [Android Studio](https://developer.android.com/studio)

### Instalação

1. **Clone ou descarregue o projeto**
   ```bash
   cd sticky_notes_app
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Execute a aplicação**
   
   **Para Desktop (Windows/Linux/macOS):**
   ```bash
   flutter run -d windows    # Para Windows
   flutter run -d linux      # Para Linux
   flutter run -d macos      # Para macOS
   ```
   
   **Para Mobile (iOS/Android):**
   ```bash
   flutter run               # Executa no dispositivo/emulador conectado
   ```

### Compilar para Distribuição

**Windows:**
```bash
flutter build windows
```
O executável estará em: `build/windows/x64/runner/Release/`

**Linux:**
```bash
flutter build linux
```
O executável estará em: `build/linux/x64/release/bundle/`

**macOS:**
```bash
flutter build macos
```
A aplicação estará em: `build/macos/Build/Products/Release/`

**Android:**
```bash
flutter build apk --release
```
O APK estará em: `build/app/outputs/flutter-apk/`

**iOS:**
```bash
flutter build ios --release
```
( Requer macOS e Xcode )

## 📁 Estrutura do Projeto

```
sticky_notes_app/
├── lib/
│   ├── main.dart                    # Ponto de entrada da aplicação
│   ├── models/
│   │   └── note.dart               # Modelo de dados da nota
│   ├── screens/
│   │   ├── home_screen.dart        # Tela principal com as notas
│   │   └── note_editor_screen.dart # Editor de notas
│   ├── services/
│   │   └── storage_service.dart    # Serviço de armazenamento
│   ├── widgets/
│   │   ├── note_card.dart         # Widget do cartão de nota
│   │   └── color_picker.dart      # Seletor de cores
│   └── utils/
│       └── constants.dart         # Constantes da aplicação
├── pubspec.yaml                    # Dependências
└── README.md                       # Este ficheiro
```

## 🛠️ Tecnologias Utilizadas

- **Flutter** - Framework UI multiplataforma
- **Dart** - Linguagem de programação
- **flutter_quill** - Editor de texto rico
- **shared_preferences** - Armazenamento local
- **uuid** - Geração de IDs únicos

## 📝 Como Usar

1. **Criar uma Nota**
   - Toque no botão "Nova Nota" (canto inferior direito)
   - Ou utilize o menu da aplicação

2. **Editar uma Nota**
   - Toque em qualquer nota existente
   - Utilize a barra de ferramentas para formatação

3. **Mudar a Cor**
   - No editor, selecione uma cor na barra superior

4. **Fixar uma Nota**
   - Toque no ícone de alfinete no editor

5. **Eliminar uma Nota**
   - Toque no ícone de lixo no cartão da nota

6. **Mover Notas**
   - Arraste qualquer nota para reorganizar o espaço de trabalho

## 🐛 Resolução de Problemas

### Erro: "flutter command not found"
Certifique-se de que o Flutter está no PATH do sistema.

### Erro ao compilar para desktop
Execute:
```bash
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
```

### Notas não aparecem
- Verifique se há permissões de armazenamento
- Reinicie a aplicação
- Verifique o log de erros: `flutter run -v`

## 🤝 Contribuir

Sinta-se à vontade para contribuir com melhorias! Pode:
- Reportar bugs
- Sugerir novas funcionalidades
- Enviar pull requests

## 📄 Licença

Este projeto está sob a licença MIT.

## 📞 Suporte

Se tiver dúvidas ou problemas:
1. Consulte a documentação do Flutter: https://docs.flutter.dev
2. Verifique as issues no GitHub
3. Contacte o desenvolvedor

---

**Desenvolvido com ❤️ usando Flutter**