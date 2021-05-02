import 'package:quiver/core.dart';

import 'rect.dart';

class Quadtree<O extends Rect> {
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
  final List<O> objects;

  /// Subnodes of the [Quadtree].
  final List<Quadtree<O>> nodes;

  @override
  int get hashCode => hashObjects([
        bounds,
        maxObjects,
        maxDepth,
        depth,
        ...objects,
        ...nodes,
      ]);

  @override
  bool operator ==(o) =>
      o is Quadtree &&
      o.bounds == bounds &&
      o.maxObjects == maxObjects &&
      o.maxDepth == maxDepth &&
      o.depth == depth &&
      o.nodes == nodes;

  /// Split the node into 4 subnodes (ne, nw, sw, se)
  void split() {
    final nextDepth = depth + 1;
    final subWidth = bounds.width / 2;
    final subHeight = bounds.height / 2;
    final x = bounds.x;
    final y = bounds.y;

    /// Top-right node
    final ne = Quadtree<O>(
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
    final nw = Quadtree<O>(
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
    final sw = Quadtree<O>(
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
    final se = Quadtree<O>(
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

    nodes.addAll([ne, nw, sw, se]);
  }

  /// Determines which node the object belongs to.
  ///
  /// Takes the [O] bounds of the area to be checked.
  /// Returns a [List<int>] of the intersecting subnodes (ne, nw, sw, se)
  List<int> getIndexes(O object) {
    final List<int> indexes = [];
    final xMidpoint = bounds.x + bounds.width / 2;
    final yMidpoint = bounds.y + bounds.height / 2;

    final startIsNorth = object.y < yMidpoint;
    final startIsWest = object.x < xMidpoint;
    final endIsEast = object.x + object.width > xMidpoint;
    final endIsSouth = object.y + object.height > yMidpoint;

    if (startIsNorth && endIsEast) indexes.add(0);
    if (startIsWest && startIsNorth) indexes.add(1);
    if (startIsWest && endIsSouth) indexes.add(2);
    if (endIsEast && endIsSouth) indexes.add(3);

    return indexes;
  }

  /// Insert the object into the node. If the node exceeds the capacity,
  /// it will split and add all objects to their corresponding subnodes.
  ///
  /// Takes [O] bounds to be inserted.
  void insert(O object) {
    late final List<int> indexes;

    /// If we have subnodes, call [insert] on the matching subnodes.
    if (nodes.isNotEmpty) {
      indexes = getIndexes(object);

      for (int i = 0; i < indexes.length; i++) {
        nodes[indexes[i]].insert(object);
      }
      return;
    }

    /// Otherwise, store object here.
    objects.add(object);

    /// Max objects reached; only split if maxDepth hasn't been reached.
    if (objects.length > maxObjects && depth < maxDepth) {
      if (nodes.isEmpty) split();

      /// Add objects to their corresponding subnodes
      for (final obj in objects) {
        getIndexes(obj).forEach((index) {
          nodes[index].insert(obj);
        });
      }

      /// Node should be cleaned up as the objects are now contained within
      /// subnodes.
      objects.clear();
    }
  }

  /// Return all objects that could collide with the given object, given
  /// bounds [O].
  List<O> retrieve(O object) {
    final indexes = getIndexes(object);
    final List<O> objects = [];

    /// Recursively retrieve objects from subnodes in the relevant indexes.
    if (nodes.isNotEmpty) {
      for (final index in indexes) {
        objects.addAll(nodes[index].retrieve(object));
      }
    }

    objects.removeDuplicates();

    return objects;
  }

  /// Clear the [Quadtree]
  void clear() {
    objects.clear();

    for (final node in nodes) {
      node.clear();
    }

    nodes.clear();
  }
}

/// Helper method to remove duplicates and preserve order.
extension<T> on List<T> {
  void removeDuplicates() {
    final Set<T> items = {};
    for (final T item in this) {
      if (items.contains(item)) remove(item);
      items.add(item);
    }
  }
}
