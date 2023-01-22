import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Providers/localization_provider.dart';
import 'package:dinar/Screens/about_screen.dart';
import 'package:dinar/Screens/calculator_screen.dart';
import 'package:dinar/Screens/Home/home_screen.dart';
import 'package:dinar/Screens/settings_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../Functions/get_it.dart';
import '../Functions/models.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int bottomNavigationBarIndex = GetIt.instance<GlobalClass>().getSettings(SettingsData.OpenCalculatorOnStartup) == 1 ? 0 : 1;
  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, value, child) {
        return Center(
          child: Directionality(
            textDirection: calculateTextDirection(context),
            child: Scaffold(
              body: IndexedStack(
                index: bottomNavigationBarIndex,
                children: [CalculatorScreen(), HomeScreen()],
              ),
              appBar: AppBar(),
              drawer: Drawer(
                child: Container(
                  width: 10.w,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        child: Column(
                          children: [
                            Text(
                              "Dinar - دینار",
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsScreen()));
                        },
                        title: Row(
                          children: [
                            Icon(Icons.settings),
                            SizedBox(width: 1.w),
                            Text('Settings'.localize(context), style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AboutScreen()));
                        },
                        title: Row(
                          children: [
                            Icon(Icons.info),
                            SizedBox(width: 1.w),
                            Text('about'.localize(context), style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: bottomNavigationBarIndex,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calculate),
                    label: 'Calculator'.localize(context),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home'.localize(context),
                  ),
                ],
                onTap: (value) {
                  setState(() {
                    bottomNavigationBarIndex = value;
                  });
                  FirebaseAnalytics.instance.logEvent(name: value == 0 ? 'calculator_screen' : 'home_screen');
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
