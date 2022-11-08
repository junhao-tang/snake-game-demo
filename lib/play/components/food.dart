import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// 1block = 1pixel
class FoodComponent extends PositionComponent {
  static const Color color = Colors.red;
  final Paint _paint;

  FoodComponent() : _paint = Paint()..color = color {
    size = Vector2(1, 1);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}
