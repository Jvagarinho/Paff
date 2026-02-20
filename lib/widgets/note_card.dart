import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/constants.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final bool isFloating;
  final VoidCallback onTap;
  final VoidCallback onOpenFloating;
  final VoidCallback onDelete;
  final Function(DragUpdateDetails) onDrag;
  final VoidCallback onDragEnd;

  const NoteCard({
    super.key,
    required this.note,
    this.isFloating = false,
    required this.onTap,
    required this.onOpenFloating,
    required this.onDelete,
    required this.onDrag,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: note.posX,
      top: note.posY,
      child: GestureDetector(
        onPanUpdate: onDrag,
        onPanEnd: (_) => onDragEnd(),
        onTap: onTap,
        child: Container(
          width: note.width,
          height: note.height,
          decoration: BoxDecoration(
            color: Color(note.color),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8.0,
                offset: const Offset(2, 2),
              ),
            ],
            border: isFloating
                ? Border.all(color: Colors.blue, width: 3)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      child: Row(
        children: [
          if (note.isPinned)
            const Icon(
              Icons.push_pin,
              size: 16,
              color: AppConstants.darkTextColor,
            ),
          if (isFloating)
            const Icon(
              Icons.open_in_new,
              size: 16,
              color: Colors.blue,
            ),
          Expanded(
            child: Text(
              note.title.isNotEmpty ? note.title : 'Sem título',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppConstants.darkTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Botão abrir em janela flutuante (apenas desktop)
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            IconButton(
              icon: Icon(
                isFloating ? Icons.open_in_new : Icons.open_in_new_outlined,
                size: 18,
                color: isFloating ? Colors.blue : AppConstants.darkTextColor,
              ),
              onPressed: onOpenFloating,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: isFloating ? 'Janela já aberta' : 'Abrir em janela flutuante',
            ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AppConstants.darkTextColor,
            ),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: AppConstants.notePadding,
      child: Text(
        note.content.isNotEmpty ? note.content : 'Clique para editar...',
        style: TextStyle(
          fontSize: 14,
          color: note.content.isNotEmpty 
              ? AppConstants.darkTextColor 
              : AppConstants.darkTextColor.withOpacity(0.5),
        ),
        maxLines: 10,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}