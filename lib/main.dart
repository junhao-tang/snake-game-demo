import 'package:flutter/material.dart';
import 'package:snake/game.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  const designSize = Size(415, 440); //  @TODO: need check on behavior
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: designSize,
    maximumSize: designSize,
    minimumSize: designSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Demo',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: createGameWidget(SnakeGame()),
      ),
    );
  }
}
