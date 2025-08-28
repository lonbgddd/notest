import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/enums/view_type.dart';
import 'package:flutter_app/app/models/note.dart';
import 'package:flutter_app/app/networking/hive/hive_service.dart';
import 'package:flutter_app/config/keys.dart';
import 'package:flutter_app/resources/pages/detail_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:url_launcher/url_launcher.dart';
import 'controller.dart';

class HomeController extends Controller {
  List<Note> _notes = [];
  List<Note> _searchResults = [];
  String searchQuery = "";
  bool isSearching = false;
  bool _isLoading = true;
  bool _gridView = false;

  bool get isLoading => _isLoading;

  bool get gridView => _gridView;
  List<Note> get notes => _searchResults;

  onInitData() async {
    _isLoading = true;
    _notes = await HiveService().getAllNotes();
    _searchResults = _notes;
    _isLoading = false;
  }

  @override
  void refreshPage() {
    _notes = HiveService().getAllNotes();
    super.refreshPage();
  }

  toggleView(ViewType view) {
    if (view == ViewType.grid) {
      _gridView = true;
    } else {
      _gridView = false;
    }
    NyStorage.save(Keys.statusViewCode, view.name);
    refreshPage();
  }

  onInitViewType() async {
    String? view = await NyStorage.read(Keys.statusViewCode,
        defaultValue: ViewType.list.name);
    if (view != null && view == ViewType.grid.name) {
      _gridView = true;
    } else {
      _gridView = false;
    }
  }

  onSearch(String query) {
    searchQuery = query;
    if (query.isEmpty) {
      isSearching = false;
      _searchResults = _notes;
      refreshPage();
    } else {
      isSearching = true;
      List<Note> arrayNote = HiveService().searchNotes(query);
      _searchResults = arrayNote;
      refreshPage();
    }
    //refresh();
  }

  openAddNote() {
    routeTo(DetailPage.path).then((value) {
      _searchResults = HiveService().getAllNotes();
      refreshPage();
    });
  }

  openDetail(Note note) {
    routeTo(DetailPage.path, data: note).then((value) {
      _searchResults = HiveService().getAllNotes();
      refreshPage();
    });
  }
}
