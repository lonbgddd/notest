import 'package:flutter_app/app/models/note.dart';
import 'package:flutter_app/config/keys.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class HiveService {
  static Box<Note>? _noteBox;

  /// Mở Hive box
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }
    _noteBox = await Hive.openBox<Note>(Keys.boxCode);
  }

  /// Thêm ghi chú mới
  Future<String> addNote({
    required String title,
    required String content,
  }) async {
    if (title.isEmpty && content.isEmpty) {
      return '';
    } else if (_noteBox == null) {
      throw Exception("Hive box is not initialized.");
    } else {
      final note = Note(
        id: const Uuid().v4(),
        title: title,
        content: content,
        createdAt: DateTime.now(),
      );
      await _noteBox?.put(note.id, note);
      return note.id;
    }
  }

  /// Cập nhật ghi chú
  Future<String> updateNote(
    Note note, {
    required String title,
    required String content,
  }) async {
    if (note.id.isEmpty) {
      throw Exception("Note ID is required for update.");
    } else if (title.isEmpty && content.isEmpty) {
      // Nếu cả title và content đều rỗng, xoá ghi chú
      await deleteNote(note.id);
      return note.id;
    } else if (!_noteBox!.containsKey(note.id)) {
      throw Exception("Note with ID ${note.id} does not exist.");
    } else if (note.title == title && note.content == content) {
      return note.id;
    } else {
      note.title = title;
      note.content = content;
      await note.save();
      return note.id;
    }
  }

  /// Xoá ghi chú
  Future<void> deleteNote(String id) async {
    await _noteBox?.delete(id);
  }

  /// Lấy danh sách tất cả ghi chú
  List<Note> getAllNotes() {
    final notes = _noteBox?.values.toList() ?? [];
    return notes..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Note> searchNotes(String query) {
    final allNotes = _noteBox?.values.toList() ?? [];
    final lowerQuery = query.toLowerCase();

    // Lọc theo từ khóa
    final filteredNotes = allNotes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();

    // Sắp xếp theo thời gian tạo (mới nhất trước)
    filteredNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filteredNotes;
  }

  /// Tìm ghi chú theo ID
  Note? getNoteById(String id) {
    return _noteBox?.get(id);
  }
}
