# 📝 Sticky Notes - Versão com Notas Flutuantes

## ✅ Funcionalidades Implementadas

### 🎯 Notas Flutuantes (Always on Top)
Agora você pode ter notas que ficam **sempre visíveis** acima de outras aplicações!

### Como usar:

#### Opção 1: Criar nova nota flutuante
1. Clique no botão **"Nota Flutuante"** (azul) no canto inferior direito
2. Uma nova nota será criada automaticamente
3. A janela ficará pequena (300x400) e sempre visível

#### Opção 2: Abrir nota existente como flutuante
1. Clique no ícone 🔗 (open_in_new) no canto superior de qualquer nota
2. A nota será aberta em modo flutuante
3. A janela ficará sempre visível sobre outras aplicações

#### Opção 3: Fixar janela principal
1. Clique no ícone 📌 na barra superior
2. A janela principal ficará sempre visível
3. Clique novamente para desfixar

### Características das notas flutuantes:
- ✅ Janela pequena e compacta (300x400)
- ✅ Sempre visível sobre outras janelas
- ✅ Pode ser movida livremente
- ✅ Mantém a cor escolhida
- ✅ Edição em tempo real
- ✅ Salva automaticamente

## 📁 Arquivos da Aplicação

O executável está em:
```
build\windows\x64\runner\Release\sticky_notes_app.exe
```

### Executar a aplicação:

**Opção 1:** Execute o atalho na área de trabalho (se criado)

**Opção 2:** Execute diretamente:
```bash
build\windows\x64\runner\Release\sticky_notes_app.exe
```

**Opção 3:** Criar novo atalho:
```bash
powershell -ExecutionPolicy Bypass -File criar_atalho.ps1
```

## 💾 Onde as notas são guardadas

As notas são guardadas localmente em:
```
%APPDATA%\com.example.sticky_notes_app\
```

## 🔄 Fluxo de trabalho recomendado

1. **Abra a aplicação principal**
2. **Crie uma nota flutuante** para uma tarefa específica
3. **Trabalhe em outras aplicações** enquanto a nota permanece visível
4. **Edite a nota** a qualquer momento
5. **Feche quando terminar** - as notas são salvas automaticamente!

## 🎨 Dicas

- Use notas flutuantes para: lembretes rápidos, lista de tarefas, números de telefone, etc.
- A janela principal pode ser fixada também usando o ícone 📌
- Notas fixadas aparecem primeiro na lista
- Arraste as notas na área de trabalho para organizá-las

---

**Pronto a usar!** 🎉

Execute agora: `build\windows\x64\runner\Release\sticky_notes_app.exe`