import 'dart:math';

import 'package:example/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quadtree_dart/quadtree_dart.dart';

class QuadtreeView extends StatefulWidget {
  @override
  _QuadtreeViewState createState() => _QuadtreeViewState();
}

class _QuadtreeViewState extends State<QuadtreeView> {
  Size? previousSize;

  List<Rect> retrieveNodes(Quadtree quadtree) {
    final List<Rect> nodes = [quadtree.bounds];

    quadtree.nodes.forEach((node) {
      nodes.addAll(retrieveNodes(node));
    });

    return nodes;
  }

  List<Rect> retrieveObjects(Quadtree quadtree) {
    final List<Rect> objects = [...quadtree.objects];

    quadtree.nodes.forEach((node) {
      objects.addAll(retrieveObjects(node));
    });

    return objects;
  }

  void insertNode(BuildContext context, TapDownDetails details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset offset = box.globalToLocal(details.globalPosition);

    final lower = context.read(lowerNodeDiameterProvider).state;
    final higher = context.read(higherNodeDiameterProvider).state;
    final diameter = lower + Random().nextDouble() * (higher - lower);

    context.read(quadtreeProvider.notifier).insert(
          offset.dx - diameter / 2,
          offset.dy - diameter / 2,
          diameter: diameter,
        );
    print('Inserted node at (${offset.dx}, ${offset.dy})');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size != previousSize) {
      previousSize = size;
      WidgetsBinding.instance?.addPostFrameCallback(
        (_) => context.read(boundsProvider).state = size,
      );
    }

    return Consumer(
      builder: (context, watch, _) {
        final quadtree = watch(quadtreeProvider);

        final nodes = retrieveNodes(quadtree);
        final objects = retrieveObjects(quadtree);

        return GestureDetector(
          onTapDown: (details) => insertNode(context, details),
          child: Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: Stack(
              children: [
                Flow(
                  delegate: NodeFlowDelegate(nodes),
                  children: nodes
                      .map(
                        (node) => Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          width: node.width,
                          height: node.height,
                        ),
                      )
                      .toList(),
                ),
                Flow(
                  delegate: ObjectFlowDelegate(objects),
                  children: objects
                      .map(
                        (object) => Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          width: object.width,
                          height: object.height,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NodeFlowDelegate extends FlowDelegate {
  NodeFlowDelegate(this.nodes);

  final List<Rect> nodes;

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; i++) {
      context.getChildSize(i);

      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          nodes[i].x,
          nodes[i].y,
          0,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(NodeFlowDelegate oldDelegate) {
    return nodes == oldDelegate.nodes;
  }
}

class ObjectFlowDelegate extends FlowDelegate {
  ObjectFlowDelegate(this.objects);

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
  bool shouldRepaint(ObjectFlowDelegate oldDelegate) {
    return objects == oldDelegate.objects;
  }
}
