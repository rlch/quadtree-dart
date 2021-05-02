import 'package:example/quadtree.dart';
import 'package:example/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Quadtree by RJM',
        debugShowCheckedModeBanner: false,
        home: App(),
      ),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
          SizedBox(
            width: 300,
            child: Sidebar(),
          ),
          Expanded(
            child: QuadtreeView(),
          ),
        ],
      ),
    );
  }
}
