import 'dart:math';

import 'package:dotted_line/dotted_line.dart';
import 'package:example/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_math/vector_math.dart' as vec;

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

      final lowerD = context.read(lowerNodeDiameterProvider).state;
      final higherD = context.read(higherNodeDiameterProvider).state;
      final diameter = lowerD + random.nextDouble() * (higherD - lowerD);

      final lowerV = context.read(lowerVelocityProvider).state;
      final higherV = context.read(higherVelocityProvider).state;
      final velocity = vec.Vector2(
        lowerV + random.nextDouble() * (higherV - lowerV),
        lowerV + random.nextDouble() * (higherV - lowerV),
      );

      context.read(quadtreeProvider.notifier).insert(
            x,
            y,
            diameter: diameter,
            dx: velocity.x,
            dy: velocity.y,
          );
    }
  }

  @override
  Widget build(BuildContext context, watch) {
    final maxObjects = watch(maxObjectsProvider).state;
    final maxDepth = watch(maxDepthProvider).state;
    final spotlightDiameter = watch(spotlightDiameterProvider).state;

    final lowerNodeDiameter = watch(lowerNodeDiameterProvider).state;
    final higherNodeDiameter = watch(higherNodeDiameterProvider).state;

    final lowerVelocity = watch(lowerVelocityProvider).state;
    final higherVelocity = watch(higherVelocityProvider).state;

    final shouldHaveVelocity = watch(shouldHaveVelocityProvider).state;
    final shouldCollide = watch(shouldCollideProvider).state;

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
            dottedDivider,
            buildSubtitle('Spotlight radius', context: context),
            Slider(
              min: 0,
              max: 300,
              divisions: 20,
              value: spotlightDiameter,
              onChanged: (v) =>
                  context.read(spotlightDiameterProvider).state = v,
              label: spotlightDiameter.round().toString(),
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
              max: 10,
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
            buildSubtitle('Object velocity range', context: context),
            RangeSlider(
              values: RangeValues(
                lowerVelocity,
                higherVelocity,
              ),
              min: -100,
              max: 100,
              divisions: 5,
              onChanged: !shouldHaveVelocity
                  ? null
                  : (range) {
                      context.read(lowerVelocityProvider).state = range.start;
                      context.read(higherVelocityProvider).state = range.end;
                    },
              labels: RangeLabels(
                lowerVelocity.toString(),
                higherVelocity.toString(),
              ),
            ),
            CheckboxListTile(
              title: Text('Objects should have velocity'),
              value: shouldHaveVelocity,
              onChanged: (v) =>
                  context.read(shouldHaveVelocityProvider).state = v!,
            ),
            CheckboxListTile(
              title: Text('Objects should collide'),
              value: shouldCollide,
              onChanged: (v) => context.read(shouldCollideProvider).state = v!,
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
