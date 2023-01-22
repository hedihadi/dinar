import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:dinar/Functions/get_it.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Providers/data_provider.dart';
import 'package:dinar/Providers/localization_provider.dart';
import 'package:dinar/Providers/theme_provider.dart';
import 'package:dinar/Screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.I.registerSingleton<GlobalClass>(GlobalClass());
  ad.MobileAds.instance.initialize();
  await Firebase.initializeApp();
  await FirebaseAnalytics.instance.logEvent(name: 'app_initialized');
  runApp(Sizer(builder: (context, orientation, deviceType) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => LocalizationProvider()),
      ChangeNotifierProvider(create: (_) => DataProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ], child: App());
  }));
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          child: child!,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      themeMode: Provider.of<ThemeProvider>(context).darkTheme == null
          ? ThemeMode.system
          : GetIt.instance<GlobalClass>().getSettings(SettingsData.DarkTheme) == true
              ? ThemeMode.dark
              : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'rudaw',
        scaffoldBackgroundColor: HexColor("#f6f4fc"),
        appBarTheme: AppBarTheme(backgroundColor: HexColor("#f6f4fc"), elevation: 0, iconTheme: IconThemeData(color: HexColor('#323c57'))),
        cardTheme: CardTheme(color: HexColor('#323c57'), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        accentColor: HexColor('#22283b'),
        bottomNavigationBarTheme:
            BottomNavigationBarThemeData(backgroundColor: HexColor('#323c57'), elevation: 0, selectedItemColor: Color(0xFFF4CA7E)),
        switchTheme: SwitchThemeData(
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Color(0xFFF4CA7E);
            }
            return HexColor("#323c57");
          }),
          thumbColor: MaterialStatePropertyAll(Color(0xFFF4CA7E)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'rudaw',
        scaffoldBackgroundColor: HexColor("#25292e"),
        appBarTheme: AppBarTheme(backgroundColor: HexColor("#25292e"), elevation: 0),
        cardTheme: CardTheme(color: HexColor('#2c3136'), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        accentColor: HexColor('#49515c'),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: HexColor('#25292e'), selectedItemColor: Color(0xFFF4CA7E)),
        drawerTheme: DrawerThemeData(
          backgroundColor: HexColor('#25292e'),
        ),
        switchTheme: SwitchThemeData(
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Color(0xFFF4CA7E);
            }
            return HexColor('#323c57');
          }),
          thumbColor: MaterialStatePropertyAll(Color(0xFFF4CA7E)),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          if (dataProvider.appState == AppState.Loading) {
            return CircularProgressIndicator();
          }
          return MainScreen();
        },
      ),
    );
  }
}
