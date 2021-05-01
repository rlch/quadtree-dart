import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quadtree_dart/quadtree_dart.dart';

final lowerNodeDiameterProvider = StateProvider<double>((ref) => 10);
final higherNodeDiameterProvider = StateProvider<double>((ref) => 20);
final boundsProvider = StateProvider<Size>((ref) => Size(200, 200));
final maxObjectsProvider = StateProvider<int>((ref) => 10);
final maxDepthProvider = StateProvider<int>((ref) => 10);

final quadtreeProvider =
    StateNotifierProvider<QuadtreeNotifier, Quadtree>((ref) {
  final bounds = ref.watch(boundsProvider).state;
  final maxObjects = ref.watch(maxObjectsProvider).state;
  final maxDepth = ref.watch(maxDepthProvider).state;

  return QuadtreeNotifier(
    bounds: Rect(
      width: bounds.width,
      height: bounds.height,
      x: 0,
      y: 0,
    ),
    maxObjects: maxObjects,
    maxDepth: maxDepth,
  );
});

class QuadtreeNotifier extends StateNotifier<Quadtree> {
  QuadtreeNotifier({
    required Rect bounds,
    required int maxObjects,
    required int maxDepth,
  }) : super(Quadtree(
          bounds,
          maxObjects: maxObjects,
          maxDepth: maxDepth,
        ));

  void insert(
    double x,
    double y, {
    required double diameter,
  }) =>
      state = state
        ..insert(Rect(
          x: x,
          y: y,
          height: diameter,
          width: diameter,
        ));

  void clear() => state = state..clear();
}
