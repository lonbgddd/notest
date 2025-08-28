import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/menu_item.dart';

class MenuToggleButton extends StatefulWidget {
  const MenuToggleButton({super.key, this.menuItems = const []});
  final List<MenuItem> menuItems;

  @override
  State<MenuToggleButton> createState() => _MenuToggleButtonState();
}

class _MenuToggleButtonState extends State<MenuToggleButton> {
  bool _isMenuOpen = false;
  OverlayEntry? _overlayEntry;

  void _toggleMenu() {
    if (_isMenuOpen) {
      _overlayEntry?.remove();
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }

    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + 40, // vị trí dưới nút menu
        left: offset.dx - 120 + 40, // canh phải
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 180,
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...widget.menuItems.map((item) {
                  return ListTile(
                    leading: item.icon,
                    title: Text(item.title),
                    onTap: () {
                      item.onTap!.call();
                      _toggleMenu();
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedCrossFade(
        firstChild: Icon(Icons.menu_book, color: Colors.black),
        secondChild: Icon(Icons.close, color: Colors.black),
        duration: Duration(milliseconds: 300),
        secondCurve: Curves.easeInOut,
        sizeCurve: Curves.easeInOut,
        crossFadeState:
            _isMenuOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      ),
      onPressed: _toggleMenu,
    );
  }
}
