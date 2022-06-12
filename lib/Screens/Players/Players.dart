import 'package:RustCompanion/Functions/LocalStorageManager.dart';
import 'package:RustCompanion/Providers/PlayersProvider.dart';
import 'package:RustCompanion/Providers/RefreshPlayersProvider.dart';
import 'package:RustCompanion/Screens/Players/PlayerWidget.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:RustCompanion/Providers/RefreshServersProvider.dart';
import 'package:RustCompanion/Providers/ServersProvider.dart';
import 'package:RustCompanion/Screens/Servers/MyServer.dart';
import 'package:sizer/sizer.dart';

class Players extends StatefulWidget {
  const Players({Key? key}) : super(key: key);

  @override
  State<Players> createState() => _MyServersState();
}

class _MyServersState extends State<Players> {
  RefreshController refresh_controller = RefreshController(initialRefresh: false);
  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-3008670047597964/8944552650',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  Widget adWidget = Container();
  @override
  void initState() {
    super.initState();
    myBanner.load().then((value) => setState(() {
          adWidget = AdWidget(ad: myBanner);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayersProvider>(builder: (context1, value, child) {
      return SmartRefresher(
        controller: refresh_controller,
        enablePullDown: true,
        header: WaterDropMaterialHeader(),
        onRefresh: () async {
          if (await LocalStorageManager().is_collect_data_enabled()) {
            await FirebaseAnalytics.instance.logEvent(
              name: "players_screen_refreshed",
            );
          }
          context1.read<RefreshPlayersProvider>().update();
          Future.delayed(const Duration(seconds: 1), () {
            refresh_controller.refreshToIdle();
          });
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: value.players.length,
              separatorBuilder: (context, position) {
                if (position == 0) {
                  if (myBanner.responseInfo == null) return Container();
                  return Container(height: myBanner.size.height.toDouble(), child: adWidget);
                } else {
                  return Container();
                }
              },
              itemBuilder: (context1, index) {
                return PlayerWidget(player: value.players[index]);
              }),
        ),
      );
    });
  }
}
