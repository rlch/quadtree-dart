import '../quadtree_dart.dart';

typedef PreOrderCallback = bool Function<O extends Rect>(O bounds);
typedef PostOrderCallback = void Function<O extends Rect>(O bounds);

extension Traversal<O extends Rect> on QuadtreeNode<O> {
  /// Visits each node in the quadtree in pre-order traversal
  /// invoking the specified callback.
  ///
  /// If the callback returns true for a given node, then the children of
  /// that node are not visited; otherwise, all child nodes are visited.
  void preOrderTraverse(PreOrderCallback callback) {
    final List<QuadtreeNode<O>> quadtrees = [this];
    while (quadtrees.isNotEmpty) {
      final quad = quadtrees.removeLast();
      if (!callback(quad.extent)) {
        quadtrees.addAll(quad.nodes ?? []);
      }
    }
  }

  /// Visits each node in the quadtree in post-order traversal
  /// invoking the specified callback.
  void postOrderTraverse(PostOrderCallback callback) {
    final List<QuadtreeNode<O>> quadtrees = [this];
    final List<QuadtreeNode<O>> next = [];

    while (quadtrees.isNotEmpty) {
      final quad = quadtrees.removeLast();
      quadtrees.addAll(quad.nodes ?? []);

      next.add(quad);
    }

    while (next.isNotEmpty) {
      final quad = next.removeLast();
      callback(quad.extent);
    }
  }
}
