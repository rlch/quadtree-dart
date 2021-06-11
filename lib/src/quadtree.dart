import 'rect.dart';

abstract class Quadtree<O> {
  Quadtree._();

  QuadtreeNode<O> get root;

  void add(O object);
  void addAll(Iterable<O> objects);
  void clear();
  List<O> retrieve(Rect extent);
  List<O> retrieveAllObjects();
  List<Rect> retrieveAllNodes();

  @override
  int get hashCode;
  @override
  bool operator ==(o);
}

abstract class QuadtreeNode<O> {
  QuadtreeNode._(this.extent);

  Rect extent;

  /// Subnodes of the [Quadtree].
  /// If `null` then we have a leaf node.
  List<QuadtreeNode<O>>? get nodes;

  void split();
  List<int> getQuadrants(Rect object);
  void add(O object);
  void addAll(Iterable<O> objects);
  List<O> retrieve(Rect extent);
  List<O> retrieveAllObjects();
  List<Rect> retrieveAllNodes();
  void clear();

  @override
  int get hashCode;
  @override
  bool operator ==(o);

  static final defaultExtent = Rect(x: 0, y: 0, height: 100, width: 100);
}
