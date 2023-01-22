import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Providers/theme_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../Functions/get_it.dart';
import '../Providers/localization_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    FirebaseAnalytics.instance.logEvent(name: 'settings_screen');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, value, child) {
        return Directionality(
          textDirection: calculateTextDirection(context),
          child: Scaffold(
            appBar: AppBar(
              title: Text('Settings'.localize(context), style: Theme.of(context).textTheme.titleLarge),
            ),
            body: SettingsList(
              sections: [
                SettingsSection(
                  title: Text('Common'.localize(context)),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      leading: Icon(Icons.language),
                      title: Text('Language'.localize(context)),
                      value: Text(context.read<LocalizationProvider>().language.localize(context)),
                      onPressed: (context) {
                        Widget dialog = AlertDialog(
                          title: Text('Change Language'.localize(context)),
                          content: Container(
                            height: 20.h,
                            width: 40.w,
                            child: ListView.builder(
                              itemCount: Provider.of<LocalizationProvider>(context, listen: false).available_languages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 1.h),
                                  child: TextButton(
                                      onPressed: () {
                                        Provider.of<LocalizationProvider>(context, listen: false)
                                            .changeLanguage(Provider.of<LocalizationProvider>(context, listen: false).available_languages[index]);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        Provider.of<LocalizationProvider>(context, listen: false).available_languages[index].localize(context),
                                        style: Theme.of(context).textTheme.titleMedium,
                                      )),
                                );
                              },
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                        showDialog(
                          context: context,
                          builder: (context) => dialog,
                        );
                      },
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) {
                        GetIt.instance<GlobalClass>().setSettings(SettingsData.OpenCalculatorOnStartup, value == true ? 1 : 0);
                        Provider.of<LocalizationProvider>(context, listen: false).notifyListeners();
                      },
                      initialValue: GetIt.instance<GlobalClass>().getSettings(SettingsData.OpenCalculatorOnStartup) == 1,
                      leading: Icon(Icons.calculate),
                      title: Text('open calculator on startup'.localize(context)),
                    ),
                    SettingsTile.switchTile(
                      description: Text("${localizePrice('2550', context)} ->  ${localizePrice('2500', context)}",
                          style: Theme.of(context).textTheme.bodySmall),
                      onToggle: (value) {
                        GetIt.instance<GlobalClass>().setSettings(SettingsData.RoundPrices, value);
                        Provider.of<LocalizationProvider>(context, listen: false).notifyListeners();
                      },
                      initialValue: GetIt.instance<GlobalClass>().getSettings(SettingsData.RoundPrices),
                      leading: Icon(Icons.one_k),
                      title: Text('round up numbers'.localize(context)),
                    ),
                    SettingsTile.switchTile(
                      description: Text("2500 ->  ${localizePrice('٢٥٠٠', context)}", style: Theme.of(context).textTheme.bodySmall),
                      onToggle: (value) {
                        GetIt.instance<GlobalClass>().setSettings(SettingsData.UseEnglishNumbers, value);
                        Provider.of<LocalizationProvider>(context, listen: false).notifyListeners();
                      },
                      initialValue: GetIt.instance<GlobalClass>().getSettings(SettingsData.UseEnglishNumbers),
                      leading: Icon(Icons.numbers),
                      title: Text('use english numbers'.localize(context)),
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) {
                        GetIt.instance<GlobalClass>().setSettings(SettingsData.DarkTheme, value);
                        Provider.of<ThemeProvider>(context, listen: false).changeTheme(value);
                      },
                      initialValue: GetIt.instance<GlobalClass>().getSettings(SettingsData.DarkTheme),
                      leading: Icon(Icons.numbers),
                      title: Text('dark theme'.localize(context)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
