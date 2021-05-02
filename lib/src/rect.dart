import 'package:quiver/core.dart';

class Rect {
  Rect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  double x;
  double y;
  final double width;
  final double height;

  double get left => x;
  double get top => y;
  double get right => x + width;
  double get bottom => y + height;

  bool intersects(Rect o) =>
      left < o.right && right > o.left && top < o.bottom && bottom > o.top;

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
