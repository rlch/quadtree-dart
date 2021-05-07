import '../../quadtree_dart.dart';
import 'quadtree_node.dart';

extension NodeConstructors<O extends Rect> on PointQuadtreeNode<O> {
  PointQuadtreeNode<O> constructAt(int i) => [
        constructNW,
        constructNE,
        constructSW,
        constructSE,
      ][i]();

  PointQuadtreeNode<O> constructNW() => PointQuadtreeNode<O>(
        extent: extent.nw,
        maxObjects: maxObjects,
        maxDepth: maxDepth,
        depth: depth + 1,
      );

  PointQuadtreeNode<O> constructNE() => PointQuadtreeNode<O>(
        extent: extent.ne,
        maxObjects: maxObjects,
        maxDepth: maxDepth,
        depth: depth + 1,
      );

  PointQuadtreeNode<O> constructSW() => PointQuadtreeNode<O>(
        extent: extent.sw,
        maxObjects: maxObjects,
        maxDepth: maxDepth,
        depth: depth + 1,
      );

  PointQuadtreeNode<O> constructSE() => PointQuadtreeNode<O>(
        extent: extent.se,
        maxObjects: maxObjects,
        maxDepth: maxDepth,
        depth: depth + 1,
      );
}
