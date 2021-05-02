import 'package:quiver/core.dart';

import 'rect.dart';

enum Quadrant { ne, nw, sw, se }

class Quadtree<O extends Rect> {
  Quadtree(
    this.bounds, {
    this.maxObjects = 10,
    this.maxDepth = 4,
    this.depth = 0,
  })  : objects = [],
        nodes = {};

  final Rect bounds;
  final int maxObjects;
  final int maxDepth;
  final int depth;

  /// Objects contained within the node
  final List<O> objects;

  /// Subnodes of the [Quadtree].
  final Map<Quadrant, Quadtree<O>> nodes;

  @override
  int get hashCode => hashObjects([
        bounds,
        maxObjects,
        maxDepth,
        depth,
        ...objects,
        ...nodes.entries,
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

    nodes
      ..[Quadrant.ne] = ne
      ..[Quadrant.nw] = nw
      ..[Quadrant.sw] = sw
      ..[Quadrant.se] = se;
  }

  /// Determines which quadrants the object belongs to.
  ///
  /// Takes the bounds of the area to be checked.
  /// Returns the intersecting subnodes (ne, nw, sw, se)
  List<Quadrant> getQuadrants(Rect object) {
    final List<Quadrant> quadrants = [];
    final xMidpoint = bounds.x + bounds.width / 2;
    final yMidpoint = bounds.y + bounds.height / 2;

    final startIsNorth = object.y < yMidpoint;
    final startIsWest = object.x < xMidpoint;
    final endIsEast = object.x + object.width > xMidpoint;
    final endIsSouth = object.y + object.height > yMidpoint;

    if (startIsNorth && endIsEast) quadrants.add(Quadrant.ne);
    if (startIsWest && startIsNorth) quadrants.add(Quadrant.nw);
    if (startIsWest && endIsSouth) quadrants.add(Quadrant.sw);
    if (endIsEast && endIsSouth) quadrants.add(Quadrant.se);

    return quadrants;
  }

  /// Insert the object into the node. If the node exceeds the capacity,
  /// it will split and add all objects to their corresponding subnodes.
  ///
  /// Takes bounds to be inserted.
  void insert(O object) {
    /// If we have subnodes, call [insert] on the matching subnodes.
    if (nodes.isNotEmpty) {
      final quadrants = getQuadrants(object);

      for (int i = 0; i < quadrants.length; i++) {
        nodes[quadrants[i]]!.insert(object);
      }
      return;
    }

    objects.add(object);

    /// Max objects reached; only split if maxDepth hasn't been reached.
    if (objects.length > maxObjects && depth < maxDepth) {
      if (nodes.isEmpty) split();

      /// Add objects to their corresponding subnodes
      for (final obj in objects) {
        getQuadrants(obj).forEach((q) {
          nodes[q]!.insert(obj);
        });
      }

      /// Node should be cleaned up as the objects are now contained within
      /// subnodes.
      objects.clear();
    }
  }

  /// Return all objects that could collide with the given object, given
  /// bounds.
  List<O> retrieve(Rect bounds) {
    final quadrants = getQuadrants(bounds);
    final List<O> objects = [...this.objects];

    /// Recursively retrieve objects from subnodes in the relevant quadrants.
    if (nodes.isNotEmpty) {
      for (final q in quadrants) {
        objects.addAll(nodes[q]!.retrieve(bounds));
      }
    }

    objects.removeDuplicates();
    return objects;
  }

  List<Rect> retrieveAllNodes([Quadtree<O>? quadtree]) {
    final List<Rect> nodes = [(quadtree ?? this).bounds];

    for (final node in (quadtree ?? this).nodes.values) {
      nodes.addAll(retrieveAllNodes(node));
    }

    return nodes;
  }

  /// Clear the [Quadtree]
  void clear() {
    objects.clear();

    for (final node in nodes.values) {
      if (node.nodes.isNotEmpty) node.clear();
    }

    nodes.clear();
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
