import 'package:cached_network_image/cached_network_image.dart';
import 'package:dinar/Screens/AuthorizedScreen/authorized_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:dinar/Functions/local_database_manager.dart';
import 'package:dinar/Functions/theme.dart';
import 'package:dinar/Screens/AuthorizedScreen/Widgets/item_widget.dart';
import 'package:dinar/Screens/AuthorizedScreen/authorized_screen_providers.dart';
import 'package:dinar/Screens/CalculatorScreen/calculator_screen.dart';
import 'package:dinar/Screens/DataScreen/data_screen.dart';
import 'package:dinar/Screens/MainScreen/main_screen.dart';
import 'package:dinar/Screens/MainScreen/main_screen_providers.dart';
import 'package:dinar/Widgets/SettingsUI/section_setting_ui.dart';
import 'package:dinar/Widgets/SettingsUI/switch_setting_ui.dart';
import 'package:dinar/Widgets/future_provider_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async => await PackageInfo.fromPlatform());

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        SectionSettingUi(
          children: [
            SwitchSettingUi(
              title: "ڕووکاری تاریک",
              subtitle: "ڕووکاری ئەپلیکەیشنەکە",
              value: (ref.watch(themeModeProvider).valueOrNull == ThemeMode.dark),
              onChanged: (value) async {
                await LocalDatabaseManager.saveSettingKey('theme', value ? ThemeMode.dark.name : ThemeMode.light.name);
                ref.invalidate(themeModeProvider);
              },
              icon: const Icon(FontAwesomeIcons.moon),
            ),
            SwitchSettingUi(
              title: "یەکەم پەڕە هەژمێر بێت؟",
              subtitle: "",
              value: (ref.watch(isFirstScreenCalculatorProvider).valueOrNull) ?? false,
              onChanged: (value) async {
                await LocalDatabaseManager.saveSettingKey('isFirstScreenCalculator', value);
                ref.invalidate(isFirstScreenCalculatorProvider);
              },
              icon: const Icon(FontAwesomeIcons.calculator),
            ),
          ],
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "جۆینی کەناڵی تەلیگرام بکە و ڕۆژانە نرخەکانت پێدەگات",
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 2,
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    launchUrl(Uri.parse('tg://resolve?domain=dinarapplication'));
                  },
                  icon: const Icon(FontAwesomeIcons.telegram),
                  label: const Text(
                    "کەناڵی تەلیگرام بکەوە",
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "لە فەیسبووک لەگەڵمانبە",
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 2,
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    launchUrl(Uri.parse('fb://profile/100082957046057'));
                  },
                  icon: const Icon(FontAwesomeIcons.facebook),
                  label: const Text(
                    "پەیجی فەیسبووک بکەوە",
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        SizedBox(height: 10.h),
        //const Divider(),
        //Text("سەرچاوەی نرخەکان", style: Theme.of(context).textTheme.titleMedium),
        //Text("نرخی ئاڵتون: ئازورا گۆڵد", style: Theme.of(context).textTheme.bodySmall),
        //Text("نرخی سوتەمەنیەکان: بەنزینخانەکانی سلێمانی", style: Theme.of(context).textTheme.bodySmall),
        //Text(
        //  " نرخی دراوەکان: ئازورا گۆڵد و exchangeratesapi.io",
        //  style: Theme.of(context).textTheme.bodySmall,
        //  textDirection: TextDirection.rtl,
        //),
        const Divider(),
        Text("${ref.watch(packageInfoProvider).valueOrNull?.version} ${ref.watch(packageInfoProvider).valueOrNull?.buildNumber}")
      ],
    );
  }
}
