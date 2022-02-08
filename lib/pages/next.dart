import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sailing_assist_mie/providers/count.dart';
import 'package:go_router/go_router.dart';

class Next extends ConsumerWidget {
  const Next({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(countProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('移動先のページ'),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Center(
        child: Text('何と ${count.state/2} 回も押しましたね！')
      )
    );
  }
}
