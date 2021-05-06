import 'package:quiver/core.dart';

import 'helpers.dart';
import 'node_constructors.dart';
import 'rect.dart';

class Quadtree<O extends Rect> {
  Quadtree({
    QuadtreeNode<O>? root,
    Rect? maxExtent,
    this.maxObjects = 10,
    this.maxDepth = 4,
    this.expandExtent = true,
  })  : assert(expandExtent || maxExtent != null),
        extent = maxExtent ?? _defaultExtent,
        root = root ??
            QuadtreeNode(
              extent: maxExtent ?? _defaultExtent,
              depth: 0,
              maxDepth: maxDepth,
              maxObjects: maxObjects,
            );

  QuadtreeNode<O> root;
  Rect extent;
  final int maxObjects;
  final int maxDepth;

  /// Whether the quadtree should expand its [extent] or not.
  /// If `true`, this means that [extent] sets the minimum bounding box.
  final bool expandExtent;

  static final _defaultExtent = Rect(x: 0, y: 0, height: 100, width: 100);

  void add(O object) {
    cover(object);
    root.add(object);
  }

  void addAll(Iterable<O> objects) => objects.forEach(add);
  void clear() => root.clear();
  List<O> retrieve(Rect extent) => root.retrieve(extent);
  List<O> retrieveAllObjects() => root.retrieveAllObjects();
  List<Rect> retrieveAllNodes([QuadtreeNode<O>? quadtree]) =>
      root.retrieveAllNodes(quadtree);

  /// Expand the quadtree to cover the object dimensions given by `bounds`.
  void cover(Rect bounds) {
    if (!expandExtent) return;

    var x0 = root.extent.left,
        x1 = root.extent.right,
        y0 = root.extent.top,
        y1 = root.extent.bottom;

    final bx0 = bounds.left,
        bx1 = bounds.right,
        by0 = bounds.top,
        by1 = bounds.bottom;

    double zx = root.extent.width;
    double zy = root.extent.height;

    QuadtreeNode<O> constructParent(int i) {
      return QuadtreeNode<O>(
        extent: Rect(
          x: i % 2 == 1 ? x0 : x0 - zx,
          y: i <= 1 ? y0 - zy : y0,
          width: zx * 2,
          height: zy * 2,
        ),
        depth: root.depth - 1,
        maxObjects: root.maxObjects,
        maxDepth: root.maxDepth,
      );
    }

    while (bx0 < x0 || bx1 > x1 || by0 < y0 || by1 > y1) {
      /// Could use a bitwise operator here; but less clean as type
      /// coercion from bool > int isn't available in Dart :'(
      /// This seems more comprehendable
      late final int i;
      if (by0 < y0) {
        if (bx0 < x0) {
          i = 0; // UL => 3
        } else {
          i = 1; // UR => 2
        }
      } else {
        if (bx0 < x0) {
          i = 2; // LL => 1
        } else {
          i = 3; // LR => 0
        }
      }

      final QuadtreeNode<O> parent = constructParent(i);
      parent.nodes = (<QuadtreeNode<O> Function()>[
        parent.constructNW,
        parent.constructNE,
        parent.constructSE,
        parent.constructSW
      ]..[(i - 3).abs()] = () => root)
          .map((f) => f())
          .toList();

      root = parent;
      x0 = root.extent.left;
      x1 = root.extent.right;
      y0 = root.extent.top;
      y1 = root.extent.bottom;
      zx *= 2;
      zy *= 2;
    }
  }
}

class QuadtreeNode<O extends Rect> {
  QuadtreeNode({
    Rect? extent,
    this.maxObjects = 10,
    this.maxDepth = 4,
    this.depth = 0,
  })  : extent = extent ?? Rect(x: 0, y: 0, height: 100, width: 100),
        nodes = [],
        objects = [];

  Rect extent;
  final int maxObjects;
  final int maxDepth;
  final int depth;

  /// Objects contained within the node
  final List<O> objects;

  /// Subnodes of the [Quadtree].
  /// If `null` then we have a leaf node.
  List<QuadtreeNode<O>>? nodes;

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
      o is QuadtreeNode &&
      o.extent == extent &&
      o.maxObjects == maxObjects &&
      o.maxDepth == maxDepth &&
      o.depth == depth &&
      o.nodes == nodes;

  /// Split the node into 4 subnodes (nw, ne, sw, se)
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
  void add(O object) {
    /// If we have subnodes, call [add] on the matching subnodes.
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

  void addAll(Iterable<O> objects) => objects.forEach(add);

  /// Return all objects that could collide with the given object, given
  /// extent.
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

  List<O> retrieveAllObjects() {
    final List<QuadtreeNode<O>> nodes = [this];
    final List<O> objects = [];

    while (nodes.isNotEmpty) {
      final node = nodes.removeLast();
      nodes.addAll(node.nodes ?? []);
      objects.addAll(node.objects);
    }

    objects.removeDuplicates();
    return objects;
  }

  List<Rect> retrieveAllNodes([QuadtreeNode<O>? quadtree]) {
    final List<Rect> nodes = [
      if (quadtree?.extent != null) (quadtree ?? this).extent
    ];

    for (final node in (quadtree ?? this).nodes ?? <QuadtreeNode<O>>[]) {
      nodes.addAll(retrieveAllNodes(node));
    }

    return nodes;
  }

  /// Clear the [Quadtree]
  void clear() {
    objects.clear();

    for (final node in nodes ?? <QuadtreeNode<O>>[]) {
      if (node.nodes?.isNotEmpty ?? false) node.clear();
    }

    nodes?.clear();
  }
}
