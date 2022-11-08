import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:snake/game.dart';
import 'package:snake/play/components/food.dart';

import 'components/field.dart';
import 'components/snake_part.dart';

Random _rand = Random();

enum MovingOrientation {
  up,
  down,
  left,
  right,
}

const Map<MovingOrientation, bool> movingOrientationVertical = {
  MovingOrientation.up: true,
  MovingOrientation.right: false,
  MovingOrientation.down: true,
  MovingOrientation.left: false,
};

class Snake {
  final SnakePartComponent head;
  late SnakePartComponent tail;
  MovingOrientation movingOrientation = MovingOrientation.up;

  bool _changedOrientation = false;

  Snake({required this.head, required int size}) {
    var curr = head;
    for (int i = 0; i < size - 1; i++) {
      curr = SnakePartComponent(
        prev: curr,
      )..position = Vector2(curr.position.x, curr.position.y + 1);
    }
    tail = curr;
  }

  Iterable<SnakePartComponent> partsFromTail() sync* {
    SnakePartComponent? curr = tail;
    while (curr != null) {
      yield curr;
      curr = curr.prev;
    }
  }

  void move() {
    partsFromTail().forEach((element) {
      element.move();
    });
    switch (movingOrientation) {
      case MovingOrientation.up:
        head.position.y -= 1;
        break;
      case MovingOrientation.down:
        head.position.y += 1;
        break;
      case MovingOrientation.left:
        head.position.x -= 1;
        break;
      case MovingOrientation.right:
        head.position.x += 1;
        break;
    }
    _changedOrientation = false;
  }

  void grow() {
    tail = SnakePartComponent(
      prev: tail,
    )..position = Vector2(tail.position.x, tail.position.y);
  }

  void setMovingOrientation(MovingOrientation newOrientation) {
    if (_changedOrientation) return;
    if (movingOrientationVertical[movingOrientation]! ^
        movingOrientationVertical[newOrientation]!) {
      movingOrientation = newOrientation;
      _changedOrientation = true;
    }
  }
}

class PlayView extends PositionComponent with HasGameRef<SnakeGame> {
  // relative to design
  // we can adapt to design by doing necessary adjustment
  // like scale, extend or whatever
  static const Offset gamePadPosition = Offset(0, 0);

  // game settings
  static const int initialSnakeSize = 5;
  static const double updateInterval = 0.15;
  static const int gridRows = 30;
  static const int gridColumns = 30;
  static final Offset spawnPosition = Offset(
    (gridColumns ~/ 2).toDouble(),
    (gridRows ~/ 2).toDouble(),
  );

  // components
  late final FieldComponent _fieldComponent;
  late FoodComponent _foodComponent;

  // internals
  late final Snake _snake;
  late final Timer _timer;

  @override
  Future<void> onLoad() async {
    size = Vector2(gridColumns.toDouble(), gridRows.toDouble());

    _fieldComponent = FieldComponent(
      gridColumns: gridColumns,
      gridRows: gridRows,
    )..position = Vector2(
        gamePadPosition.dx,
        gamePadPosition.dy,
      );
    _snake = Snake(
      head: SnakePartComponent()
        ..position = Vector2(spawnPosition.dx, spawnPosition.dy),
      size: initialSnakeSize,
    );

    _timer = Timer(
      updateInterval,
      onTick: () {
        _snake.move();
        gameConditionCheck();
      },
      repeat: true,
    );
    await add(_fieldComponent);
    _fieldComponent.addAll(_snake.partsFromTail());
    spawnNewFood();
  }

  void handleKeyEvent(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.keyD) {
      _snake.setMovingOrientation(MovingOrientation.right);
    } else if (key == LogicalKeyboardKey.keyA) {
      _snake.setMovingOrientation(MovingOrientation.left);
    } else if (key == LogicalKeyboardKey.keyW) {
      _snake.setMovingOrientation(MovingOrientation.up);
    } else if (key == LogicalKeyboardKey.keyS) {
      _snake.setMovingOrientation(MovingOrientation.down);
    }
  }

  @override
  void update(double dt) {
    _timer.update(dt);
  }

  void gameConditionCheck() {
    final position = _snake.head.position;
    if (position.x < 0 || position.x >= gridColumns) {
      gameOver();
      return;
    }
    if (position.y < 0 || position.y >= gridRows) {
      gameOver();
      return;
    }

    if (position.y == _foodComponent.position.y &&
        position.x == _foodComponent.position.x) {
      _fieldComponent.remove(_foodComponent);
      snakeGrow();
      _fieldComponent.add(_snake.tail);
      spawnNewFood();
      return;
    }

    _snake.partsFromTail().forEach((element) {
      if (element == _snake.head) return;
      if (element.position.x == position.x &&
          element.position.y == position.y) {
        gameOver();
      }
    });
  }

  void gameOver() {
    _timer.stop();
    print("game over");
  }

  void snakeGrow() {
    _snake.grow();
  }

  void spawnNewFood() {
    do {
      _foodComponent = FoodComponent()
        ..position = Vector2(
          _rand.nextInt(gridColumns).toDouble(),
          _rand.nextInt(gridRows).toDouble(),
        );
    } while (_snake.partsFromTail().any(
          (element) =>
              element.position.x == _foodComponent.position.x &&
              element.position.y == _foodComponent.position.y,
        ));
    _fieldComponent.add(_foodComponent);
  }
}
