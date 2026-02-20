# 📝 Sticky Notes - Sincronização e Single Instance

## ✅ Problemas Resolvidos

### 1. **Múltiplos Gestores (Single Instance)** ✅
**Problema:** Ao clicar no ícone do aplicativo várias vezes, abriam-se múltiplos gestores de notas.

**Solução:** Implementado mecanismo de lock baseado em arquivo:
- Cria um arquivo lock no diretório temporário
- Verifica se já existe outra instância em execução pelo PID
- Se já existir, fecha silenciosamente sem abrir novo gestor
- Libera o lock automaticamente ao fechar

**Resultado:** Apenas UM gestor principal pode estar aberto por vez!

### 2. **Sincronização entre Janelas** ✅
**Problema:** Quando editava uma nota flutuante, o gestor não mostrava as alterações.

**Solução:** Implementado sistema de auto-refresh:
- Verificação periódica a cada 2 segundos
- Detecção automática quando a janela ganha foco
- Comparador de timestamps para identificar alterações
- Indicador visual quando há dados desatualizados

**Resultado:** O gestor detecta automaticamente quando dados mudam em outras janelas!

### 3. **Indicador Visual de Alterações** ✅
**Problema:** Não havia feedback quando os dados estavam desatualizados.

**Solução:** Adicionados indicadores visuais:
- Badge "Atualizar" vermelho no título quando há alterações pendentes
- Barra superior fica laranja (em vez de âmbar) quando desatualizada
- Botão de sincronização (🔄) aparece na barra de ferramentas
- Snackbar informa "Dados atualizados de outra janela"

**Resultado:** Usuário sempre sabe quando precisa atualizar os dados!

## 🚀 Funcionalidades Atuais

### Janela Principal (Gestor):
- ✅ **Single Instance** - Apenas um gestor aberto por vez
- ✅ **Auto-refresh** - Atualiza automaticamente a cada 2 segundos
- ✅ **Detecção de foco** - Verifica alterações quando ganha foco
- ✅ **Indicador visual** - Mostra quando dados estão desatualizados
- ✅ **Botão de sync** - Atualização manual com um clique

### Janelas Flutuantes:
- ✅ **Independentes** - Cada nota é um processo separado
- ✅ **Always on Top** - Sempre visíveis sobre outras janelas
- ✅ **Salvamento automático** - Guarda ao fazer alterações
- ✅ **Feedback visual** - Botão "Guardar" aparece quando há alterações

### Sincronização:
- ✅ **Detecta alterações** em tempo real
- ✅ **Compara timestamps** para identificar mudanças
- ✅ **Atualiza a lista** automaticamente quando necessário

## 📦 Executável:

```
build\windows\x64\runner\Release\sticky_notes_app.exe
```

## 🎯 Como Usar:

### Fluxo Recomendado:

1. **Abra o aplicativo** (apenas um gestor pode estar aberto)
2. **Crie uma nota flutuante** clicando em "Nota Flutuante"
3. **Edite a nota** na janela flutuante
4. **Clique em Guardar** - a nota permanece aberta
5. **Alterne para o gestor** - ele detecta alterações automaticamente
6. **Clique em 🔄 ou aguarde** - dados são atualizados

### Indicadores:

- **Badge vermelho "Atualizar"** → Há alterações pendentes
- **Barra laranja** → Dados desatualizados
- **Botão 🔄 visível** → Clique para atualizar manualmente
- **Badge desaparece** → Dados estão sincronizados

## 💾 Onde as notas são guardadas:

```
%APPDATA%\com.example.sticky_notes_app\
```

## ⚙️ Arquivo de Lock:

```
%TEMP%\sticky_notes_manager.lock
```

Este arquivo contém o PID do processo do gestor atual. Se o gestor crashar, o arquivo é limpo automaticamente na próxima inicialização.

---

**Pronto a usar! Execute agora e teste a sincronização!** 🎉