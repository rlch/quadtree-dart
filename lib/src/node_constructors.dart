import '../quadtree_dart.dart';

extension NodeConstructors<O extends Rect> on QuadtreeNode<O> {
  double get _subWidth => extent.width / 2;
  double get _subHeight => extent.height / 2;

  QuadtreeNode<O> constructAt(int i) => [
        constructNW,
        constructNE,
        constructSW,
        constructSE,
      ][i]();

  QuadtreeNode<O> constructNW() => QuadtreeNode<O>(
        extent: Rect(
          x: extent.x,
          y: extent.y,
          width: _subWidth,
          height: _subHeight,
        ),
        maxObjects: maxObjects,
        maxDepth: maxDepth,
        depth: depth + 1,
      );

  QuadtreeNode<O> constructNE() => QuadtreeNode<O>(
        extent: Rect(
          x: extent.x + _subWidth,
          y: extent.y,
          width: _subWidth,
          height: _subHeight,
        ),
        maxObjects: maxObjects,
        maxDepth: maxDepth,
        depth: depth + 1,
      );

  QuadtreeNode<O> constructSW() => QuadtreeNode<O>(
        extent: Rect(
          x: extent.x,
          y: extent.y + _subHeight,
          width: _subWidth,
          height: _subHeight,
        ),
        maxObjects: maxObjects,
        maxDepth: maxDepth,
        depth: depth + 1,
      );

  QuadtreeNode<O> constructSE() => QuadtreeNode<O>(
        extent: Rect(
          x: extent.x + _subWidth,
          y: extent.y + _subHeight,
          width: _subWidth,
          height: _subHeight,
        ),
        maxObjects: maxObjects,
        maxDepth: maxDepth,
        depth: depth + 1,
      );
}
