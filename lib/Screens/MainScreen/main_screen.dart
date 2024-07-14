import 'package:dinar/Screens/AuthorizedScreen/authorized_screen_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:dinar/Functions/admob_consent_helper.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Screens/AuthorizedScreen/authorized_screen.dart';
import 'package:dinar/Screens/MainScreen/main_screen_providers.dart';
import 'package:dinar/Widgets/future_provider_widget.dart';
import 'package:dinar/Widgets/localized_text.dart';

final loadingProvider = FutureProvider((ref) async {
  final a = await ref.watch(authProvider.future);
  final b = await ref.watch(localizationProvider.future);
});

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AdmobConsentHelper().initialize();
    ref.read(isFirstScreenCalculatorProvider);
    ref.read(backendProvider);
    //wait until the essential providers are loaded before showing the authorized screen
    if (ref.watch(loadingProvider).hasValue == false) {
      return FutureProviderWidget(provider: loadingProvider);
    }
    if (ref.watch(localizationProvider).value == null) {
      return FutureProviderWidget(provider: loadingProvider);
    }
    return Directionality(textDirection: ref.watch(directionalityProvider), child: AuthorizedScreen());
  }
}

class LoadingScreen extends ConsumerWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
          child: SizedBox(
        height: 10.h,
        width: 10.h,
        child: const CircularProgressIndicator(
          strokeWidth: 15,
        ),
      )),
    );
  }
}
