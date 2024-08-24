import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RacePage extends HookConsumerWidget {
  const RacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = useState(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Race'),
      ),
      body: Center(
        // HookConsumer is a builder widget that allows you to read providers and utilise hooks.
        child: Text(
          '${counter.value}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          counter.value++;
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
