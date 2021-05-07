import '../../quadtree_dart.dart';
import 'quadtree_node.dart';

class PointQuadtree<O extends Rect> implements Quadtree<O> {
  PointQuadtree({
    PointQuadtreeNode<O>? root,
    Rect? maxExtent,
    this.maxObjects = 10,
    this.maxDepth = 4,
    this.expandExtent = true,
  })  : extent = maxExtent ?? Quadtree.defaultExtent,
        root = root ??
            PointQuadtreeNode(
              extent: maxExtent ?? Quadtree.defaultExtent,
              depth: 0,
              maxDepth: maxDepth,
              maxObjects: maxObjects,
            );

  @override
  PointQuadtreeNode<O> root;
  Rect extent;
  final int maxObjects;
  final int maxDepth;

  @override
  void add(O object) => root.add(object);
  @override
  void addAll(Iterable<O> objects) => objects.forEach(add);
  @override
  void clear() => root.clear();
  @override
  List<O> retrieve(Rect extent) => root.retrieve(extent);
  @override
  List<O> retrieveAllObjects() => root.retrieveAllObjects();
  @override
  List<Rect> retrieveAllNodes() => root.retrieveAllNodes();

  /// Whether the quadtree should expand its [extent] or not.
  /// If `true`, this means that [extent] sets the minimum bounding box.
  final bool expandExtent;

  /// Expand the quadtree to cover the object dimensions given by `bounds`.
  void cover(Rect bounds) {
    var x0 = root.extent.x0,
        x1 = root.extent.x1,
        y0 = root.extent.y0,
        y1 = root.extent.y1;

    final bx0 = bounds.x0, bx1 = bounds.x1, by0 = bounds.y0, by1 = bounds.y1;

    PointQuadtreeNode<O> constructParent(Rect rootExtent, int i) {
      return PointQuadtreeNode<O>(
        extent: Rect(
          x: i % 2 == 0 ? x0 : x0 - rootExtent.width,
          y: i >= 2 ? y0 - rootExtent.height : y0,
          width: rootExtent.width * 2,
          height: rootExtent.height * 2,
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
      // late final int i = (by0 < y0 ? 1 : 0) << 1 | (bx0 < x0 ? 1 : 0);
      late final int i;
      if (by0 < y0) {
        if (bx0 < x0) {
          i = 3;
        } else {
          i = 2;
        }
      } else {
        if (bx0 < x0) {
          i = 1;
        } else {
          i = 0;
        }
      }

      final PointQuadtreeNode<O> parent = constructParent(root.extent, i);
      // parent.nodes = (<PointQuadtreeNode<O> Function()>[
      //   parent.constructNW,
      //   parent.constructNE,
      //   parent.constructSE,
      //   parent.constructSW
      // ]..[i] = () => root)
      //     .map((f) => f())
      //     .toList();
      parent
        ..split()
        ..nodes![i] = root;

      assert(
        parent.nodes!.every(
          (node) => node.extent.width == parent.extent.width / 2,
        ),
      );

      root = parent;
      extent = root.extent;
      x0 = root.extent.x0;
      x1 = root.extent.x1;
      y0 = root.extent.y0;
      y1 = root.extent.y1;
    }
  }
}
