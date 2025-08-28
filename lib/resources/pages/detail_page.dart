import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter_app/app/controllers/detail_controller.dart';
import 'package:flutter_app/app/models/note.dart';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class DetailPage extends NyStatefulWidget<DetailController> {
  static RouteView path = ("/detail", (_) => DetailPage());

  DetailPage({super.key}) : super(child: () => _HomePageState());
}

class _HomePageState extends NyPage<DetailPage> {
  late QuillController _controller;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  Timer? _saveTimer;
  Note? note;

  @override
  get init => () async {
        /// Uncomment the code below to fetch the number of stars for the Nylo repository
        // Map<String, dynamic>? githubResponse = await api<ApiService>(
        //         (request) => request.githubInfo(),
        // );
        // _stars = githubResponse?["stargazers_count"];
        if (io.Platform.isAndroid || io.Platform.isIOS) {
          // Enable virtual keyboard on mobile platforms
          _editorFocusNode.requestFocus();
        }
        note = widget.data<Note>();
        List<Map<String, dynamic>> delta = [];
        if (note != null) {
          widget.controller.updateNoteId(note!.id);
          widget.controller.note = note;
          List<dynamic> rawList = jsonDecode(note?.content ?? "");
          delta = List<Map<String, dynamic>>.from(rawList);
        }

        final doc = note != null
            ? Document.fromDelta(Delta.fromJson(delta))
            : Document()
          ..insert(0, '');

        _controller = QuillController(
            document: doc, selection: TextSelection.collapsed(offset: 0));
        _controller.addListener(
          () {
            if (_saveTimer?.isActive ?? false) _saveTimer?.cancel();
            _saveTimer = Timer(const Duration(seconds: 3), () {
              // Save document to local storage or backend
              widget.controller
                  .addListener(_controller.document.toDelta().toJson());
            });
            final json = jsonEncode(_controller.document.toDelta().toJson());
            print(json);
          },
        );
      };

  /// Define the Loading style for the page.
  /// Options: LoadingStyle.normal(), LoadingStyle.skeletonizer(), LoadingStyle.none()
  /// uncomment the code below.
  @override
  LoadingStyle get loadingStyle => LoadingStyle.normal();

  /// The [view] method displays your page.
  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Detail Page"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              widget.controller
                  .addBackPopup(_controller.document.toDelta().toJson())
                  .whenComplete(() => Navigator.of(context).pop());
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.black),
              onPressed: () {
                if (note != null) {
                  widget.controller.onDeleteNote(note!.id).whenComplete(() =>
                      Navigator.of(context).pop()); // Xoá ghi chú và quay lại
                } else {
                  Navigator.of(context)
                      .pop(); // Chỉ quay lại nếu không có ghi chú
                }
              },
            ),
          ],
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 0),
      body: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller,
            config: QuillSimpleToolbarConfig(
              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
            ),
          ),
          Expanded(
            child: QuillEditor(
              focusNode: _editorFocusNode,
              scrollController: _editorScrollController,
              controller: _controller,
              config: QuillEditorConfig(
                placeholder: 'Start writing your notes...',
                padding: const EdgeInsets.all(16),
                autoFocus: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
