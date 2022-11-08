import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// 1block = 1pixel
class SnakePartComponent extends PositionComponent {
  static const Color color = Colors.green;
  final Paint _paint;

  SnakePartComponent? prev;

  SnakePartComponent({this.prev}) : _paint = Paint()..color = color {
    size = Vector2(1, 1);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }

  void move() {
    if (prev == null) return;
    position.x = prev!.position.x;
    position.y = prev!.position.y;
  }
}
