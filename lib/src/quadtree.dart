import 'package:quadtree_dart/src/rect.dart';

class Quadtree {
  Quadtree(
    this.bounds, {
    this.maxObjects = 10,
    this.maxDepth = 4,
    this.depth = 0,
  })  : objects = [],
        nodes = [];

  final Rect bounds;
  final int maxObjects;
  final int maxDepth;
  final int depth;

  /// Objects contained within the node
  final List<Rect> objects;

  /// Subnodes of the [Quadtree].
  final List<Quadtree> nodes;

  /// Split the node into 4 subnodes (ne, nw, sw, se)
  void split() {
    final nextDepth = depth + 1;
    final subWidth = bounds.width / 2;
    final subHeight = bounds.height / 2;
    final x = bounds.x;
    final y = bounds.y;

    /// Top-right node
    nodes[0] = Quadtree(
      Rect(
        x: x + subWidth,
        y: y,
        width: subWidth,
        height: subHeight,
      ),
      maxObjects: maxObjects,
      maxDepth: maxDepth,
      depth: nextDepth,
    );

    /// Top-left node
    nodes[1] = Quadtree(
      Rect(
        x: x,
        y: y,
        width: subWidth,
        height: subHeight,
      ),
      maxObjects: maxObjects,
      maxDepth: maxDepth,
      depth: nextDepth,
    );

    /// Bottom-left node
    nodes[2] = Quadtree(
      Rect(
        x: x,
        y: y + subHeight,
        width: subWidth,
        height: subHeight,
      ),
      maxObjects: maxObjects,
      maxDepth: maxDepth,
      depth: nextDepth,
    );

    /// Bottom-right node
    nodes[3] = Quadtree(
      Rect(
        x: x + subWidth,
        y: y + subHeight,
        width: subWidth,
        height: subHeight,
      ),
      maxObjects: maxObjects,
      maxDepth: maxDepth,
      depth: nextDepth,
    );
  }

  /// Determines which node the object belongs to.
  ///
  /// Takes the [Rect] bounds of the area to be checked.
  /// Returns a [List<int>] of the intersecting subnodes (ne, nw, sw, se)
  List<int> getIndexes(Rect rect) {
    final List<int> indexes = [];
    final xMidpoint = bounds.x + bounds.width / 2;
    final yMidpoint = bounds.y + bounds.height / 2;

    final startIsNorth = rect.y < yMidpoint;
    final startIsWest = rect.x < xMidpoint;
    final endIsEast = rect.x + rect.width > xMidpoint;
    final endIsSouth = rect.y + rect.height > yMidpoint;

    if (startIsNorth && endIsEast) indexes.add(0);
    if (startIsWest && startIsNorth) indexes.add(1);
    if (startIsWest && endIsSouth) indexes.add(2);
    if (endIsEast && endIsSouth) indexes.add(3);

    return indexes;
  }

  /// Insert the object into the node. If the node exceeds the capacity,
  /// it will split and add all objects to their corresponding subnodes.
  ///
  /// Takes [Rect] bounds to be inserted.
  void insert(Rect rect) {
    late final List<int> indexes;

    /// If we have subnodes, call [insert] on the matching subnodes.
    if (nodes.isNotEmpty) {
      indexes = getIndexes(rect);

      for (int i = 0; i < indexes.length; i++) {
        nodes[indexes[i]].insert(rect);
      }
      return;
    }

    /// Otherwise, store object here.
    objects.add(rect);

    /// Max objects reached; only split if maxDepth hasn't been reached.
    if (objects.length > maxObjects && depth < maxDepth) {
      if (nodes.isEmpty) {
        split();
      }

      /// Add objects to their corresponding subnodes
      objects.forEach((object) {
        getIndexes(object).forEach((index) {
          nodes[index].insert(object);
        });
      });

      /// Node should be cleaned up as the objects are now contained within
      /// subnodes.
      objects.clear();
    }
  }

  /// Return all objects that could collide with the given object, given
  /// bounds [Rect].
  List<Rect> retrieve(rect) {
    final indexes = getIndexes(rect);
    final List<Rect> objects = [];

    /// Recursively retrieve objects from subnodes in the relevant indexes.
    if (nodes.isNotEmpty) {
      indexes.forEach((index) {
        objects.addAll(nodes[index].retrieve(rect));
      });
    }

    objects.removeDuplicates();

    return objects;
  }

  /// Clear the [Quadtree]
  void clear() {
    objects.clear();

    nodes.forEach((node) {
      node.clear();
    });

    nodes.clear();
  }
}

/// Helper method to remove duplicates and preserve order.
extension<T> on List<T> {
  void removeDuplicates() {
    Set<T> items = {};
    for (T item in this) {
      if (items.contains(item)) this.remove(item);
      items.add(item);
    }
  }
}
