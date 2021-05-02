import 'dart:math';

import 'package:quadtree_dart/quadtree_dart.dart';
import 'package:vector_math/vector_math.dart';

class VelocityObject extends Rect {
  VelocityObject({
    required double x,
    required double y,
    required double width,
    required double height,
    this.dx = 0,
    this.dy = 0,
  }) : super(
          x: x,
          y: y,
          width: width,
          height: height,
        );

  double dx;
  double dy;

  double get mass => sqrt(width * height);
  void tick() => this
    ..x += dx / 60
    ..y += dy / 60;

  /// Collide with left/right bounds
  void collideLR() => dx *= -1;

  /// Collide with top/bottom bounds
  void collideTB() => dy *= -1;

  /// https://en.wikipedia.org/wiki/Elastic_collision
  void collide(
    VelocityObject o2,
  ) {
    final o1 = this;
    final x1 = Vector2(
      o1.x + o1.width / 2,
      o1.y + o1.height / 2,
    );
    final x2 = Vector2(
      o2.x + o2.width / 2,
      o2.y + o2.height / 2,
    );

    final v1 = Vector2(o1.dx, o1.dy);
    final v2 = Vector2(o2.dx, o2.dy);

    final double m1 = o1.mass;
    final double m2 = o2.mass;

    final v1p = v1 -
        ((x1 - x2) *
            (v1 - v2).dot(x1 - x2) /
            ((x1 - x2).length2) *
            (2 * m2 / (m1 + m2)));

    final v2p = v2 -
        ((x2 - x1) *
            (v2 - v1).dot(x2 - x1) /
            ((x2 - x1).length2) *
            (2 * m1 / (m1 + m2)));

    if (v1p.isInfinite || v2p.isInfinite || v1p.isNaN || v2p.isNaN) return;

    o1
      ..dx = v1p.x
      ..dy = v1p.y;

    o2
      ..dx = v2p.x
      ..dy = v2p.y;
  }
}
