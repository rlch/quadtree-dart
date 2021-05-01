import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quadtree_dart/quadtree_dart.dart';

final boundsProvider = StateProvider<Rect>((ref) => Rect(
      x: 0,
      y: 0,
      height: 200,
      width: 200,
    ));

final maxObjectsProvider = StateProvider<int>((ref) => 10);
final maxDepthProvider = StateProvider<int>((ref) => 4);

final quadtreeProvider =
    StateNotifierProvider<QuadtreeNotifier, Quadtree>((ref) {
  final bounds = ref.watch(boundsProvider).state;
  final maxObjects = ref.watch(maxObjectsProvider).state;
  final maxDepth = ref.watch(maxDepthProvider).state;

  return QuadtreeNotifier(
    bounds: bounds,
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

  static const double height = 20;
  static const double width = 20;

  void insert(double x, double y) => state = state
    ..insert(Rect(
      x: x + height / 2,
      y: y + width / 2,
      height: height,
      width: width,
    ));
}
