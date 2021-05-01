import 'package:example/quadtree.dart';
import 'package:example/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: App(),
      ),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: Sidebar(),
        ),
        VerticalDivider(),
        Expanded(
          child: QuadtreeView(),
        ),
      ],
    );
  }
}
