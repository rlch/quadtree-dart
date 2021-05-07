import 'package:quiver/core.dart';

import '../../quadtree_dart.dart';
import '../helpers.dart';
import 'node_constructors.dart';

class PointQuadtreeNode<O extends Rect> implements QuadtreeNode<O> {
  PointQuadtreeNode({
    Rect? extent,
    this.maxObjects = 10,
    this.maxDepth = 4,
    this.depth = 0,
  })  : extent = extent ?? Rect(x: 0, y: 0, height: 100, width: 100),
        nodes = [],
        objects = [];

  @override
  Rect extent;
  final int maxObjects;
  final int maxDepth;
  final int depth;

  @override
  final List<O> objects;

  @override
  List<PointQuadtreeNode<O>>? nodes;

  @override
  int get hashCode => hashObjects([
        extent,
        maxObjects,
        maxDepth,
        depth,
        ...objects,
        ...?nodes,
      ]);

  @override
  bool operator ==(o) =>
      o is PointQuadtreeNode &&
      o.extent == extent &&
      o.maxObjects == maxObjects &&
      o.maxDepth == maxDepth &&
      o.depth == depth &&
      o.nodes == nodes;

  /// Split the node into 4 subnodes (nw, ne, sw, se)
  @override
  void split() {
    nodes = [
      constructNW(),
      constructNE(),
      constructSW(),
      constructSE(),
    ];
  }

  /// Determines which quadrants the object belongs to.
  ///
  /// Takes the extent of the area to be checked.
  /// Returns the intersecting subnodes (nw, ne sw, se)
  @override
  List<int> getQuadrants(Rect object) {
    final List<int> quadrants = [];
    final xMidpoint = extent.x + extent.width / 2;
    final yMidpoint = extent.y + extent.height / 2;

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
  /// Takes extent to be inserted.
  @override
  void add(O object) {
    /// If we have subnodes, call [add] on the matching subnodes.
    if (nodes?.isNotEmpty ?? false) {
      final quadrants = getQuadrants(object);

      for (final i in quadrants) {
        nodes![i].add(object);
      }
      return;
    }

    objects.add(object);

    /// Max objects reached; only split if maxDepth hasn't been reached.
    if (objects.length > maxObjects && depth < maxDepth) {
      if (nodes?.isEmpty ?? true) split();

      /// Add objects to their corresponding subnodes
      for (final obj in objects) {
        getQuadrants(obj).forEach((i) {
          nodes![i].add(obj);
        });
      }

      /// Node should be cleaned up as the objects are now contained within
      /// subnodes.
      objects.clear();
    }
  }

  @override
  void addAll(Iterable<O> objects) => objects.forEach(add);

  /// Return all objects that could collide with the given object, given
  /// extent.
  @override
  List<O> retrieve(Rect extent) {
    final quadrants = getQuadrants(extent);
    final List<O> objects = [...this.objects];

    /// Recursively retrieve objects from subnodes in the relevant quadrants.
    if (nodes?.isNotEmpty ?? false) {
      for (final q in quadrants) {
        objects.addAll(nodes![q].retrieve(extent));
      }
    }

    objects.removeDuplicates();
    return objects;
  }

  @override
  List<O> retrieveAllObjects() {
    final List<PointQuadtreeNode<O>> nodes = [this];
    final List<O> objects = [];

    while (nodes.isNotEmpty) {
      final node = nodes.removeLast();
      nodes.addAll(node.nodes ?? []);
      objects.addAll(node.objects);
    }

    objects.removeDuplicates();
    return objects;
  }

  @override
  List<Rect> retrieveAllNodes() {
    final List<PointQuadtreeNode<O>> next = [this];
    final List<Rect> nodes = [];

    while (next.isNotEmpty) {
      final node = next.removeLast();
      nodes.add(node.extent);
      next.addAll(node.nodes ?? []);
    }

    return nodes;
  }

  /// Clear the [Quadtree]
  @override
  void clear() {
    objects.clear();

    for (final node in nodes ?? <PointQuadtreeNode<O>>[]) {
      if (node.nodes?.isNotEmpty ?? false) node.clear();
    }

    nodes?.clear();
  }
}
