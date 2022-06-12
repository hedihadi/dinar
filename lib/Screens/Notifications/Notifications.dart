import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:RustCompanion/Providers/NotificationsProvider.dart';
import 'package:RustCompanion/Providers/RefreshServersProvider.dart';
import 'package:RustCompanion/Providers/ServersProvider.dart';
import 'package:RustCompanion/Screens/Notifications/Notification.dart';
import 'package:RustCompanion/Screens/Servers/MyServer.dart';
import 'package:RustCompanion/utils/models.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);
  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  RefreshController refresh_controller = RefreshController(initialRefresh: false);
  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-5924426514255017/3495392228',
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
    return Consumer<NotificationsProvider>(builder: (context1, value, child) {
      return ListView.separated(
          shrinkWrap: true,
          itemCount: value.notifications.length,
          separatorBuilder: (context, position) {
            if (position == 0) {
              if (myBanner.responseInfo == null) return Container();
              return Container(height: myBanner.size.height.toDouble(), child: adWidget);
            } else {
              return Container();
            }
          },
          itemBuilder: (context1, index) {
            return NotificationWidget(notification: value.notifications[index]);
          });
    });
  }
}
