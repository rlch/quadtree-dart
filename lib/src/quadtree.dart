import 'dart:math';

import 'package:quiver/core.dart';

import 'rect.dart';

class Quadtree<O extends Rect> {
  Quadtree({
    required this.bounds,
    this.maxObjects = 10,
    this.maxDepth = 4,
    this.depth = 0,
  })  : shouldCover = true,
        objects = [];

  Rect bounds;
  final int maxObjects;
  final int maxDepth;
  final int depth;
  final bool shouldCover;

  /// Objects contained within the node
  final List<O> objects;

  /// Subnodes of the [Quadtree].
  List<Quadtree<O>>? nodes;
  bool get isLeaf => nodes == null;

  @override
  int get hashCode => hashObjects([
        bounds,
        maxObjects,
        maxDepth,
        depth,
        ...objects,
        ...?nodes,
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
      bounds: Rect(
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
      bounds: Rect(
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
      bounds: Rect(
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
      bounds: Rect(
        x: x + subWidth,
        y: y + subHeight,
        width: subWidth,
        height: subHeight,
      ),
      maxObjects: maxObjects,
      maxDepth: maxDepth,
      depth: nextDepth,
    );

    nodes = [nw, ne, sw, se];
  }

  /// Determines which quadrants the object belongs to.
  ///
  /// Takes the bounds of the area to be checked.
  /// Returns the intersecting subnodes (ne, nw, sw, se)
  List<int> getQuadrants(Rect object) {
    final List<int> quadrants = [];
    final xMidpoint = bounds.x + bounds.width / 2;
    final yMidpoint = bounds.y + bounds.height / 2;

    final startIsNorth = object.y < yMidpoint;
    final startIsWest = object.x < xMidpoint;
    final endIsEast = object.x + object.width > xMidpoint;
    final endIsSouth = object.y + object.height > yMidpoint;

    if (startIsWest && startIsNorth) quadrants.add(0);
    if (startIsNorth && endIsEast) quadrants.add(1);
    if (startIsWest && endIsSouth) quadrants.add(2);
    if (endIsEast && endIsSouth) quadrants.add(3);

    return quadrants;
  }

  /// Insert the object into the node. If the node exceeds the capacity,
  /// it will split and add all objects to their corresponding subnodes.
  ///
  /// Takes bounds to be inserted.
  void add(O object) {
    /// If we have subnodes, call [insert] on the matching subnodes.
    if (nodes?.isNotEmpty ?? false) {
      final quadrants = getQuadrants(object);

      for (int i = 0; i < quadrants.length; i++) {
        nodes![quadrants[i]].add(object);
      }
      return;
    }

    objects.add(object);

    /// Max objects reached; only split if maxDepth hasn't been reached.
    if (objects.length > maxObjects && depth < maxDepth) {
      if (nodes?.isEmpty ?? false) split();

      /// Add objects to their corresponding subnodes
      for (final obj in objects) {
        getQuadrants(obj).forEach((q) {
          nodes![q].add(obj);
        });
      }

      /// Node should be cleaned up as the objects are now contained within
      /// subnodes.
      objects.clear();
    }
  }

  void cover(O object) {
    if (bounds == null) {
      bounds = Rect(
        x: object.x.floorToDouble(),
        y: object.y.floorToDouble(),
        height: object.height.ceilToDouble(),
        width: object.width.ceilToDouble(),
      );
      return;
    } else {
      final z = max(bounds.width, 1);
    }
  }

  /// Return all objects that could collide with the given object, given
  /// bounds.
  List<O> retrieve(Rect bounds) {
    final quadrants = getQuadrants(bounds);
    final List<O> objects = [...this.objects];

    /// Recursively retrieve objects from subnodes in the relevant quadrants.
    if (nodes?.isNotEmpty ?? false) {
      for (final q in quadrants) {
        objects.addAll(nodes![q].retrieve(bounds));
      }
    }

    objects.removeDuplicates();
    return objects;
  }

  List<Rect> retrieveAllNodes([Quadtree<O>? quadtree]) {
    final List<Rect> nodes = [
      if (quadtree?.bounds != null || bounds != null) (quadtree ?? this).bounds
    ];

    for (final node in (quadtree ?? this).nodes ?? <Quadtree<O>>[]) {
      nodes.addAll(retrieveAllNodes(node));
    }

    return nodes;
  }

  /// Clear the [Quadtree]
  void clear() {
    objects.clear();

    for (final node in nodes ?? <Quadtree<O>>[]) {
      if (node.nodes?.isNotEmpty ?? false) node.clear();
    }

    nodes!.clear();
  }
}

/// Helper method to remove duplicates and preserve order.
extension<T> on List<T> {
  void removeDuplicates() {
    final Set<T> items = {};
    for (final T item in [...this]) {
      if (items.contains(item)) remove(item);
      items.add(item);
    }
  }
}
