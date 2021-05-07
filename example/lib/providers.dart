import 'dart:ui';

import 'package:example/object.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quadtree_dart/quadtree_dart.dart';

final shouldHaveVelocityProvider = StateProvider<bool>((ref) => true);
final shouldCollideProvider = StateProvider<bool>((ref) => true);
final lowerNodeDiameterProvider = StateProvider<double>((ref) => 10);
final higherNodeDiameterProvider = StateProvider<double>((ref) => 20);
final lowerVelocityProvider = StateProvider<double>((ref) => -30);
final higherVelocityProvider = StateProvider<double>((ref) => 30);
final boundsProvider = StateProvider<Size>((ref) => Size(200, 200));
final maxObjectsProvider = StateProvider<int>((ref) => 3);
final maxDepthProvider = StateProvider<int>((ref) => 4);
final spotlightDiameterProvider = StateProvider<double>((ref) => 100);

final quadtreeProvider =
    StateNotifierProvider<QuadtreeNotifier, RectQuadtree<VelocityObject>>(
        (ref) {
  final bounds = ref.watch(boundsProvider).state;
  final maxObjects = ref.watch(maxObjectsProvider).state;
  final maxDepth = ref.watch(maxDepthProvider).state;

  return QuadtreeNotifier(
    maxExtent: Rect(
      width: bounds.width,
      height: bounds.height,
      x: 0,
      y: 0,
    ),
    maxObjects: 1,
    maxDepth: maxDepth,
  );
});

class QuadtreeNotifier extends StateNotifier<RectQuadtree<VelocityObject>> {
  QuadtreeNotifier({
    required Rect maxExtent,
    required int maxObjects,
    required int maxDepth,
  }) : super(RectQuadtree(
          maxExtent: maxExtent,
          maxObjects: maxObjects,
          maxDepth: maxDepth,
        ));

  void insert(
    double x,
    double y, {
    required double diameter,
    required double dx,
    required double dy,
  }) =>
      state = state
        ..add(VelocityObject(
          x: x,
          y: y,
          height: diameter,
          width: diameter,
          dx: dx,
          dy: dy,
        ));

  void clear() => state = state..clear();
}
