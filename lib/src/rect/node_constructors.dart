import '../../quadtree_dart.dart';
import 'quadtree_node.dart';

extension NodeConstructors<O extends Rect> on RectQuadtreeNode<O> {
  RectQuadtreeNode<O> constructAt(int i) => [
        constructNW,
        constructNE,
        constructSW,
        constructSE,
      ][i]();

  RectQuadtreeNode<O> constructNW() => RectQuadtreeNode<O>(
        extent: extent.nw,
        maxObjects: maxObjects,
        maxDepth: maxDepth,
        depth: depth + 1,
      );

  RectQuadtreeNode<O> constructNE() => RectQuadtreeNode<O>(
        extent: extent.ne,
        maxObjects: maxObjects,
        maxDepth: maxDepth,
        depth: depth + 1,
      );

  RectQuadtreeNode<O> constructSW() => RectQuadtreeNode<O>(
        extent: extent.sw,
        maxObjects: maxObjects,
        maxDepth: maxDepth,
        depth: depth + 1,
      );

  RectQuadtreeNode<O> constructSE() => RectQuadtreeNode<O>(
        extent: extent.se,
        maxObjects: maxObjects,
        maxDepth: maxDepth,
        depth: depth + 1,
      );
}
