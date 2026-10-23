/// Splits [items] into page groups according to [maxPerPage].
List<List<T>> chunkImagesForPages<T>(List<T> items, int maxPerPage) {
  if (items.isEmpty || maxPerPage <= 0) return const [];
  final List<List<T>> pages = [];
  for (int i = 0; i < items.length; i += maxPerPage) {
    final int end =
        (i + maxPerPage < items.length) ? i + maxPerPage : items.length;
    pages.add(items.sublist(i, end));
  }
  return pages;
}
