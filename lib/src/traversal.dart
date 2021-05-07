import '../quadtree_dart.dart';

typedef PreOrderCallback = bool Function<O extends Rect>(O bounds);
typedef PostOrderCallback = void Function<O extends Rect>(O bounds);

extension Traversal<O extends Rect> on Quadtree<O> {
  /// Visits each node in the quadtree in pre-order traversal
  /// invoking the specified callback.
  ///
  /// If the callback returns true for a given node, then the children of
  /// that node are not visited; otherwise, all child nodes are visited.
  void preOrderTraverse(PreOrderCallback callback) {
    final List<QuadtreeNode<O>> quadtrees = [root];
    final List<Rect> extents = [extent];

    while (quadtrees.isNotEmpty) {
      final quad = quadtrees.removeLast();
      final extent = extents.removeLast();

      if (!callback(extent)) {
        for (int i = 0; i < (quad.nodes?.length ?? 0); i++) {
          quadtrees.add(quad.nodes![i]);
          extents.add(extent.quadrant(i));
        }
      }
    }
  }

  /// Visits each node in the quadtree in post-order traversal
  /// invoking the specified callback.
  void postOrderTraverse(PostOrderCallback callback) {
    final List<QuadtreeNode<O>> quadtrees = [root];
    final List<Rect> extents = [extent];
    final List<Rect> next = [];

    while (quadtrees.isNotEmpty) {
      final quad = quadtrees.removeLast();
      final extent = extents.removeLast();

      for (int i = 0; i < (quad.nodes?.length ?? 0); i++) {
        quadtrees.add(quad.nodes![i]);
        extents.add(extent.quadrant(i));
      }

      next.add(extent);
    }

    while (next.isNotEmpty) {
      final extent = next.removeLast();
      callback(extent);
    }
  }
}
