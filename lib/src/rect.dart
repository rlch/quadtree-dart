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

  double get x0 => x;
  double get y0 => y;
  double get x1 => x + width;
  double get y1 => y + height;

  double get xm => x + width / 2;
  double get ym => y + height / 2;

  Rect quadrant(int i) => [nw, ne, sw, se][i];

  Rect get nw => Rect(
        x: x,
        y: y,
        width: width / 2,
        height: height / 2,
      );

  Rect get ne => Rect(
        x: xm,
        y: y,
        width: width / 2,
        height: height / 2,
      );

  Rect get sw => Rect(
        x: x,
        y: ym,
        width: width / 2,
        height: height / 2,
      );

  Rect get se => Rect(
        x: xm,
        y: ym,
        width: width / 2,
        height: height / 2,
      );

  bool intersects(Rect o) => x1 < o.x1 && x0 > o.x0 && y1 < o.y1 && y0 > o.y0;

  @override
  int get hashCode => hash4(x, y, width, height);

  @override
  bool operator ==(o) =>
      o is Rect &&
      o.x == x &&
      o.y == y &&
      o.width == width &&
      o.height == height;

  @override
  String toString() => '(left: $x0, right: $x1, top: $y0, bottom: $y1)';
}
