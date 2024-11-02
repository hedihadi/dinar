import 'dart:io';
import 'package:color_print/color_print.dart';
import 'package:dinar/Functions/analytics_manager.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:upgrader/upgrader.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Screens/MainScreen/main_screen.dart';
import 'package:dinar/firebase_options.dart';
import 'Functions/theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:sizer/sizer.dart';

final _revenueCatConfiguration = PurchasesConfiguration(Platform.isAndroid ? 'goog_LlCDPzDskVSBJhWpQvxdbuNsLFy' : 'appl_eqiIImrSxvAweggWipqxMOgYidj');
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('ku', timeago.KuMessages());
  await Firebase.initializeApp(options: Platform.isAndroid ? DefaultFirebaseOptions.android : DefaultFirebaseOptions.ios);
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  final fcmToken = await FirebaseMessaging.instance.getToken();
  logInfo('fcm: $fcmToken');
  MobileAds.instance.initialize();
  AnalyticsManager.requestFirebaseMessagingPermission();
  final facebookAppEvents = FacebookAppEvents();
  facebookAppEvents.setAdvertiserTracking(enabled: true);
  Purchases.configure(_revenueCatConfiguration);
  await dotenv.load(fileName: ".env");
  //for some reason this is needed to allow error printing
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  runApp(ProviderScope(
    child: Sizer(builder: (context, orientation, deviceType) {
      return const App();
    }),
  ));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider).valueOrNull;
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      themeMode: themeMode ?? ThemeMode.system,
      theme: FlexThemeData.light(
        fontFamily: 'NotoKufi',
        scheme: FlexScheme.greyLaw,
        usedColors: 2,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 25,
        appBarStyle: FlexAppBarStyle.background,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 1,
          blendTextTheme: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
          elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
          segmentedButtonSchemeColor: SchemeColor.primary,
          inputDecoratorSchemeColor: SchemeColor.primary,
          inputDecoratorBackgroundAlpha: 43,
          inputDecoratorRadius: 8.0,
          inputDecoratorUnfocusedHasBorder: false,
          inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
          popupMenuRadius: 6.0,
          popupMenuElevation: 4.0,
          dialogElevation: 3,
          dialogRadius: 20,
          drawerIndicatorSchemeColor: SchemeColor.primary,
          bottomNavigationBarMutedUnselectedLabel: false,
          bottomNavigationBarMutedUnselectedIcon: false,
          menuRadius: 6.0,
          menuElevation: 4.0,
          menuBarRadius: 0.0,
          menuBarElevation: 1.0,
          navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
          navigationBarMutedUnselectedLabel: false,
          navigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
          navigationBarMutedUnselectedIcon: false,
          navigationBarIndicatorSchemeColor: SchemeColor.primary,
          navigationBarIndicatorOpacity: 1.00,
          navigationBarBackgroundSchemeColor: SchemeColor.background,
          navigationBarElevation: 0,
          navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
          navigationRailMutedUnselectedLabel: false,
          navigationRailSelectedIconSchemeColor: SchemeColor.onPrimary,
          navigationRailMutedUnselectedIcon: false,
          navigationRailIndicatorSchemeColor: SchemeColor.primary,
          navigationRailIndicatorOpacity: 1.00,
        ),
        keyColors: const FlexKeyColors(
          useSecondary: true,
          useTertiary: true,
        ),
        tones: FlexTones.oneHue(Brightness.light),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ).copyWith(),
      darkTheme: FlexThemeData.dark(
        fontFamily: 'NotoKufi',
        scheme: FlexScheme.greyLaw,
        usedColors: 2,
        surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
        blendLevel: 25,
        appBarStyle: FlexAppBarStyle.background,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 1,
          blendTextTheme: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
          elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
          segmentedButtonSchemeColor: SchemeColor.primary,
          inputDecoratorSchemeColor: SchemeColor.primary,
          inputDecoratorBackgroundAlpha: 43,
          inputDecoratorRadius: 8.0,
          inputDecoratorUnfocusedHasBorder: false,
          inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
          popupMenuRadius: 6.0,
          popupMenuElevation: 4.0,
          dialogElevation: 3,
          dialogRadius: 20,
          drawerIndicatorSchemeColor: SchemeColor.primary,
          bottomNavigationBarMutedUnselectedLabel: false,
          bottomNavigationBarMutedUnselectedIcon: false,
          menuRadius: 6.0,
          menuElevation: 4.0,
          menuBarRadius: 0.0,
          menuBarElevation: 1.0,
          navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
          navigationBarMutedUnselectedLabel: false,
          navigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
          navigationBarMutedUnselectedIcon: false,
          navigationBarIndicatorSchemeColor: SchemeColor.primary,
          navigationBarIndicatorOpacity: 1.00,
          navigationBarBackgroundSchemeColor: SchemeColor.background,
          navigationBarElevation: 0,
          navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
          navigationRailMutedUnselectedLabel: false,
          navigationRailSelectedIconSchemeColor: SchemeColor.onPrimary,
          navigationRailMutedUnselectedIcon: false,
          navigationRailIndicatorSchemeColor: SchemeColor.primary,
          navigationRailIndicatorOpacity: 1.00,
        ),
        keyColors: const FlexKeyColors(
          useSecondary: true,
          useTertiary: true,
        ),
        tones: FlexTones.oneHue(Brightness.dark),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ).copyWith(
        inputDecorationTheme: AppTheme.darkTheme.inputDecorationTheme
            .copyWith(focusedBorder: AppTheme.darkTheme.inputDecorationTheme.focusedBorder!.copyWith(borderSide: BorderSide.none)),
        textTheme: AppTheme.darkTheme.textTheme.copyWith(
          labelSmall: AppTheme.darkTheme.textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w300),
          //  titleLarge: GoogleFonts.bebasNeueTextTheme(AppTheme.darkTheme.textTheme).titleLarge,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: UpgradeAlert(
        child: const LoaderOverlay(overlayColor: Colors.black54, child: MainScreen()),
      ),
    );
  }
}
