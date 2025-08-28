import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CustomQuillToolbar extends StatelessWidget
    implements PreferredSizeWidget {
  final QuillController controller;

  const CustomQuillToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      color: Theme.of(context).canvasColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Undo button
          QuillToolbarHistoryButton(
            controller: controller,
            isUndo: true,
          ),

          const SizedBox(width: 8),

          // Font size dropdown
          QuillToolbarFontSizeButton(
            controller: controller,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
