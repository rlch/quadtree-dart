import 'dart:math';

import 'package:dotted_line/dotted_line.dart';
import 'package:example/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const String instructions =
    'Tune the algorithm\'s parameters with the sliders below. Add nodes to the quadtree by clicking on the viewport, or by generating in bulk.';

class Sidebar extends ConsumerWidget {
  final nController = TextEditingController();

  final divider = const SizedBox(height: 10);
  final dottedDivider = Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: DottedLine(
      dashColor: Colors.grey.shade400,
    ),
  );

  void generateObjects(BuildContext context) {
    final n = int.tryParse(nController.text);
    if (n == null) return;

    final random = Random();
    final size = MediaQuery.of(context).size;

    for (int i = 0; i < n; i++) {
      final x = random.nextDouble() * (size.width - 300);
      final y = random.nextDouble() * size.height;

      final lower = context.read(lowerNodeDiameterProvider).state;
      final higher = context.read(higherNodeDiameterProvider).state;
      final diameter = lower + Random().nextDouble() * (higher - lower);

      context.read(quadtreeProvider.notifier).insert(
            x,
            y,
            diameter: diameter,
          );
    }
  }

  @override
  Widget build(BuildContext context, watch) {
    final maxObjects = watch(maxObjectsProvider).state;
    final maxDepth = watch(maxDepthProvider).state;

    var lowerNodeDiameter = watch(lowerNodeDiameterProvider).state;
    var higherNodeDiameter = watch(higherNodeDiameterProvider).state;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Quadtree',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            Center(
              child: Text(
                'Richard Mathieson',
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            divider,
            divider,
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(primary: Colors.deepPurple),
                onPressed: () =>
                    launch('https://github.com/rlch/quadtree-dart'),
                icon: Icon(FontAwesomeIcons.github),
                label: Text('View my code'),
              ),
            ),
            dottedDivider,
            buildSubtitle('Instructions:', context: context),
            Text(
              instructions,
            ),
            dottedDivider,
            buildSubtitle('Max Objects (per subnode)', context: context),
            Slider(
              min: 2,
              max: 20,
              divisions: 20,
              value: maxObjects.toDouble(),
              onChanged: (v) =>
                  context.read(maxObjectsProvider).state = v.toInt(),
              label: maxObjects.toString(),
            ),
            dottedDivider,
            buildSubtitle('Max Depth (from root node)', context: context),
            Slider(
              min: 2,
              max: 20,
              divisions: 10,
              value: maxDepth.toDouble(),
              onChanged: (v) =>
                  context.read(maxDepthProvider).state = v.toInt(),
              label: maxDepth.toString(),
            ),
            dottedDivider,
            buildSubtitle('Node diameter range', context: context),
            RangeSlider(
              values: RangeValues(
                lowerNodeDiameter,
                higherNodeDiameter,
              ),
              min: 5,
              max: 50,
              onChanged: (range) {
                context.read(lowerNodeDiameterProvider).state = range.start;
                context.read(higherNodeDiameterProvider).state = range.end;
              },
              labels: RangeLabels(
                lowerNodeDiameter.toString(),
                higherNodeDiameter.toString(),
              ),
            ),
            dottedDivider,
            TextFormField(
              controller: nController,
              decoration: InputDecoration(
                labelText: 'Generate n objects',
                hintText: 'n',
              ),
            ),
            divider,
            Row(
              children: [
                TextButton(
                  onPressed: () => generateObjects(context),
                  child: Text('Generate'),
                ),
                const SizedBox(width: 10),
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.red,
                  ),
                  onPressed: () {
                    context.read(quadtreeProvider.notifier).clear();
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSubtitle(
    String subtitle, {
    required BuildContext context,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          subtitle,
          style: Theme.of(context).textTheme.subtitle2,
        ),
      );
}
