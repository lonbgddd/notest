import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/note.dart';
import 'package:flutter_app/app/networking/hive/hive_service.dart';

import 'controller.dart';

class DetailController extends Controller {
  String? _noteId;
  Note? _note;

  String get noteId => _noteId ?? '';
  updateNoteId(String id) {
    _noteId = id;
  }

  Note? get note => _note;
  set note(Note? n) {
    _note = n;
  }

  /// Gọi khi editor thay đổi (ví dụ như onChanged từ Quill, Zefyr, etc.)
  Future<void> addListener(List<Map<String, dynamic>> json,
      {Note? note}) async {
    final buffer = StringBuffer();

    if (note != null) {
      _noteId = note.id;
      _note = note;
    }

    for (var op in json) {
      if (op.containsKey('insert')) {
        buffer.write(op['insert']);
      }
    }

    final lines = buffer.toString().split('\n');
    final title = lines.isNotEmpty ? lines.first.trim() : '';
    final content = jsonEncode(json);

    final hive = HiveService();

    // Nếu title & content đều rỗng và đã có noteId -> XÓA
    if ((title.isEmpty && content.isEmpty) && noteId.isNotEmpty) {
      await hive.deleteNote(noteId);
      print("🗑️ Đã xoá note vì không còn nội dung: $noteId");
      _note = null;
      _noteId = null;
      return;
    }

    if (noteId.isEmpty) {
      _noteId = await hive.addNote(title: title, content: content);
      _note = Note(id: _noteId!, title: title, content: content);
    } else {
      _note = Note(id: _noteId!, title: title, content: content);

      await hive.updateNote(_note!, title: title, content: content);
      print("✏️ Đã cập nhật note: $_noteId");
    }
  }

  Future<void> addBackPopup(List<Map<String, dynamic>> json) async {
    final lines = json[0]['insert'].toString().split('\n');
    final title = lines.isNotEmpty ? lines.first.trim() : '';
    final content = jsonEncode(json);

    print('Log title: $title');
    print('Log content: $content');

    final hive = HiveService();

    if ((title.isEmpty && content.isEmpty) && noteId.isNotEmpty) {
      await hive.deleteNote(noteId);
      print("🗑️ Đã xoá note khi thoát vì không có nội dung: $noteId");
      _note = null;
      _noteId = null;
      return;
    }

    if (noteId.isEmpty) {
      if (title.isNotEmpty || content.isNotEmpty) {
        _noteId = await hive.addNote(title: title, content: content);
        _note = Note(id: _noteId!, title: title, content: content);
        print("📝 Đã lưu note tạm: $_noteId");
      }
    } else {
      await hive.updateNote(note!, title: title, content: content);
      print("📌 Đã lưu khi thoát trang: $_noteId");
    }
  }

  Future<void> onDeleteNote(String id) async {
    await HiveService().deleteNote(id);
    print("🗑️ Đã xóa note: $id");
  }
}
