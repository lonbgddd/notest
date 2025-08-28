enum ViewType { list, grid }

extension ViewTypeExtension on ViewType {
  String get name {
    switch (this) {
      case ViewType.list:
        return "List";
      case ViewType.grid:
        return "Grid";
    }
  }
}
