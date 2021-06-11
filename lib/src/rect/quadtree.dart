import '../../quadtree_dart.dart';
import 'quadtree_node.dart';

class RectQuadtree<O extends Rect> implements Quadtree<O> {
  RectQuadtree({
    RectQuadtreeNode<O>? root,
    Rect? maxExtent,
    this.maxObjects = 10,
    this.maxDepth = 4,
  }) : root = root ??
            RectQuadtreeNode(
              extent: maxExtent ?? QuadtreeNode.defaultExtent,
              depth: 0,
              maxDepth: maxDepth,
              maxObjects: maxObjects,
            );

  @override
  RectQuadtreeNode<O> root;
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
}
