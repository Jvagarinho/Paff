import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ColorPicker extends StatelessWidget {
  final int selectedColor;
  final Function(int) onColorSelected;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: AppConstants.noteColors.map((color) {
          final isSelected = color.value == selectedColor;
          return GestureDetector(
            onTap: () => onColorSelected(color.value),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.black,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}