import 'package:quiver/core.dart';

class Point {
  Point({
    required this.x,
    required this.y,
  });

  double x;
  double y;

  @override
  int get hashCode => hash2(x, y);
  @override
  bool operator ==(o) => o is Point && o.x == x && o.y == y;

  @override
  String toString() => '($x, $y)';
}
