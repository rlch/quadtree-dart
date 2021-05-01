import 'package:quiver/core.dart';

class Rect {
  const Rect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  @override
  int get hashCode => hash4(x, y, width, height);

  @override
  bool operator ==(o) =>
      o is Rect &&
      o.x == x &&
      o.y == y &&
      o.width == width &&
      o.height == height;
}
