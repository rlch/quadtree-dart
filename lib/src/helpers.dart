extension ListHelpers<T> on List<T> {
  /// Helper method to remove duplicates and preserve order.
  void removeDuplicates() {
    final Set<T> items = {};
    for (final T item in [...this]) {
      if (items.contains(item)) remove(item);
      items.add(item);
    }
  }
}

extension IterableHelpers<T> on Iterable<T?> {
  Iterable<T> whereNotNull() sync* {
    for (final element in this) {
      if (element != null) yield element;
    }
  }
}
