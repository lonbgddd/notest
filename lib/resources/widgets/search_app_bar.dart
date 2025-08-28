import 'package:flutter/material.dart';

class SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool showSearch;
  final TextEditingController searchController;
  final VoidCallback onToggleSearch;

  SearchHeaderDelegate({
    required this.showSearch,
    required this.searchController,
    required this.onToggleSearch,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: showSearch
                ? TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm...",
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )
                : Text(
                    "My Notes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              showSearch ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: onToggleSearch,
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 100;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant SearchHeaderDelegate oldDelegate) {
    return oldDelegate.showSearch != showSearch;
  }
}
