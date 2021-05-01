import 'package:example/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quadtree_dart/quadtree_dart.dart';

class QuadtreeView extends ConsumerWidget {
  List<Rect> retrieveObjects(Quadtree quadtree) {
    final List<Rect> objects = [];

    quadtree.nodes.forEach((node) {
      objects.addAll(retrieveObjects(node));
    });

    return objects;
  }

  void insertNode(BuildContext context, TapDownDetails details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset offset = box.globalToLocal(details.globalPosition);
    context.read(quadtreeProvider.notifier).insert(offset.dx, offset.dy);
    print('Inserted node at (${offset.dx}, ${offset.dy})');
  }

  @override
  Widget build(BuildContext context, watch) {
    final quadtree = watch(quadtreeProvider);
    final objects = retrieveObjects(quadtree);

    print(objects);

    return GestureDetector(
      onTapDown: (details) => insertNode(context, details),
      child: Container(
        color: Colors.white,
        child: Flow(
          delegate: QuadtreeFlowDelegate(objects),
          children: objects
              .map(
                (obj) => Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  width: 20,
                  height: 20,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class QuadtreeFlowDelegate extends FlowDelegate {
  QuadtreeFlowDelegate(this.objects);

  final List<Rect> objects;

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; i++) {
      context.getChildSize(i);

      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          objects[i].x,
          objects[i].y,
          0,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(QuadtreeFlowDelegate oldDelegate) {
    return objects == oldDelegate.objects;
  }
}
