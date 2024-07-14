import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:dinar/Functions/admob_consent_helper.dart';
import 'package:dinar/Screens/AuthorizedScreen/authorized_screen.dart';
import 'package:dinar/Screens/MainScreen/main_screen.dart';
import 'package:dinar/Screens/MainScreen/main_screen_providers.dart';
import 'package:dinar/Widgets/localized_text.dart';

class FutureProviderWidget<T> extends ConsumerWidget {
  const FutureProviderWidget({super.key, required this.provider});
  final ProviderBase<AsyncValue<T>> provider; // Use ProviderBase for flexibility

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(provider);
    print(asyncValue);
    return Scaffold(
      body: asyncValue.when(
        data: (data) => const Text('loaded'),
        error: (error, stackTrace) {
          print(error);
          print(stackTrace);
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LocalizedText(text: 'A problem occurred:'),
                Text(error.toString()),
                ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(provider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"))
              ],
            ),
          );
        },
        loading: () => const LoadingScreen(),
      ),
    );
  }
}
