import 'package:flutter/material.dart';
import '/bootstrap/helpers.dart';
import '/resources/themes/styles/color_styles.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'dart:convert';

/// [Text] Extensions
extension NyText on Text {
  Text setColor(
      BuildContext context, Color Function(ColorStyles color) newColor,
      {String? themeId}) {
    return copyWith(
        style: TextStyle(
            color: newColor(ThemeColor.get(context, themeId: themeId))));
  }
}

/// [BuildContext] Extensions
extension NyApp on BuildContext {
  /// Get the current theme color
  ColorStyles get color => ThemeColor.get(this);
}

/// [TextStyle] Extensions
extension NyTextStyle on TextStyle {
  TextStyle? setColor(
      BuildContext context, Color Function(ColorStyles color) newColor,
      {String? themeId}) {
    return copyWith(color: newColor(ThemeColor.get(context, themeId: themeId)));
  }
}

extension NyString on String {
  /// Convert từ JSON Delta (chuỗi JSON của Flutter Quill)
  /// sang String thuần để hiển thị (không giữ định dạng)
  String get quillJsonToPlainText {
    List<Map<String, dynamic>> delta;

    try {
      // Cố gắng parse JSON string
      List<dynamic> convert = jsonDecode(this);
      delta = List<Map<String, dynamic>>.from(convert);

      // Kiểm tra định dạng đầu ra
      if (delta is! List) return '';
    } catch (e) {
      print('❌ Lỗi decode JSON: $e');
      return '';
    }

    final buffer = StringBuffer();

    for (var op in delta) {
      print("op: $op");
      buffer.write(op['insert']);
    }

    return buffer.toString();
  }
}
