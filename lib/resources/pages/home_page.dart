import 'package:flutter_app/app/models/enums/view_type.dart';
import 'package:flutter_app/app/models/menu_item.dart';
import 'package:flutter_app/bootstrap/extensions.dart';
import 'package:flutter_app/resources/widgets/logo_widget.dart';
import 'package:flutter_app/resources/widgets/menu_widget.dart';

import '/app/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class HomePage extends NyStatefulWidget<HomeController> {
  static RouteView path = ("/home", (_) => HomePage());

  HomePage({super.key}) : super(child: () => _HomePageState());
}

class _HomePageState extends NyPage<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  get init => () async {
        widget.controller.onInitData();

        await widget.controller.onInitViewType();
        _searchController.addListener(
          () {
            print("");
            widget.controller
                .onSearch(_searchController.text.trim().toString());
          },
        );
      };

  @override
  void activate() {
    super.activate();
  }

  @override
  bool get stateManaged => true;

  @override
  Map<String, Function> get stateActions => {
        "update_view_list": () {
          setState(() {});
        }
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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 8),
                  Text(
                    "My Notes",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                  ),
                  MenuToggleButton(
                    menuItems: [
                      MenuItem(
                          title: "Chế độ lưới",
                          icon: Icon(Icons.grid_view),
                          onTap: () {
                            widget.controller.toggleView(ViewType.grid);
                          }),
                      MenuItem(
                          title: "Chế độ danh sách",
                          icon: Icon(Icons.view_list),
                          onTap: () {
                            widget.controller.toggleView(ViewType.list);
                          })
                    ],
                  ),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySearchBar(
                child: Container(
                  height: 60,
                  alignment: Alignment.center,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(-5, 5),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm...",
                      prefixIcon: Icon(Icons.search),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: !widget.controller.gridView
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final note = widget.controller.notes[index];
                          return InkWell(
                            onTap: () => widget.controller.openDetail(note),
                            child: Card(
                              child: ListTile(
                                title: Text(note.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                    note.content.quillJsonToPlainText,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          );
                        },
                        childCount: widget.controller.notes.length,
                      ),
                    )
                  : SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final note = widget.controller.notes[index];
                          return InkWell(
                            onTap: () => widget.controller.openDetail(note),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(note.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Text(note.content.quillJsonToPlainText,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: widget.controller.notes.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => widget.controller.openAddNote(),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller.onInitData();
  }

  @override
  Map<AppLifecycleState, Function()> get lifecycleActions => {
        AppLifecycleState.resumed: () {
          widget.controller.refreshPage();
          print("object resumed");
        },
        AppLifecycleState.paused: () {
          print("object paused");
        },
        AppLifecycleState.inactive: () {
          print("object inactive");
        },
        AppLifecycleState.detached: () {
          print("object detached");
        },
      };
}

class _StickySearchBar extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySearchBar({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 4 : 0,
      child: child,
    );
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant _StickySearchBar oldDelegate) => false;
}
