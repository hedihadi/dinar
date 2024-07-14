import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinar/Screens/MainScreen/main_screen_providers.dart';

class LocalizedText extends ConsumerWidget {
  const LocalizedText({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(ref.watch(localizationProvider.notifier).translate(text));
  }
}
