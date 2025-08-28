import 'package:flutter/material.dart';

class MenuItem {
  final Icon icon;
  final String title;
  final VoidCallback? onTap;

  MenuItem({
    required this.icon,
    required this.title,
    this.onTap,
  });
}
