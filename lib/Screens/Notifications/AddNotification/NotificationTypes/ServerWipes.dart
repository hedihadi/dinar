import 'package:RustCompanion/Providers/AddNewNotificationProvider.dart';
import 'package:RustCompanion/Providers/NotificationsProvider.dart';
import 'package:RustCompanion/Providers/ServersProvider.dart';
import 'package:RustCompanion/Screens/Notifications/AddNotification/AddNewNotification.dart';
import 'package:RustCompanion/Screens/Notifications/AddNotification/AddNotification_ServerWidget.dart';
import 'package:RustCompanion/Screens/Notifications/AddNotification/SelectServer.dart';
import 'package:RustCompanion/utils/ColorManager.dart';
import 'package:RustCompanion/utils/models.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';

class ServerWipes extends StatefulWidget {
  const ServerWipes({Key? key}) : super(key: key);

  @override
  State<ServerWipes> createState() => _ServerWipesState();
}

class _ServerWipesState extends State<ServerWipes> {
  RewardedAd? ad;

  @override
  void initState() {
    super.initState();
    RewardedAd.load(
        request: AdRequest(),
        adUnitId: 'ca-app-pub-3008670047597964/6819832633',
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            this.ad = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        SizedBox(height: 5.h),
        ExpansionTileCard(
          title: Text(
            "Select A Server",
            style: TextStyle(color: ColorManager().minor),
          ),
          children: [
            Container(
              color: ColorManager().background1,
              height: 40.h,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: context.read<ServersProvider>().servers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(10.sp),
                      child: SelectServer_Server(server: context.read<ServersProvider>().servers[index]),
                    );
                  }),
            ),
          ],
        ),
        Consumer<AddNewNotificationProvider>(builder: (context1, value, child) {
          return value.selected_server == null
              ? Container()
              : ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                        style: new TextStyle(
                          fontSize: 11.sp,
                        ),
                        children: <TextSpan>[
                          new TextSpan(text: "You'll get a Notification when "),
                          new TextSpan(text: '${value.selected_server!.name}', style: new TextStyle(color: Colors.amber, fontSize: 13.sp)),
                          new TextSpan(text: " Wipes!"),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: ElevatedButton(
                        onPressed: () async {
                          ad?.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) async {
                                setNotification(value);
                              }) ??
                              setNotification(value);
                        },
                        child: Text("Add Notification"),
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange[700])),
                      ),
                    ),
                  ],
                );
        }),
      ],
    );
  }

  setNotification(value) async {
    NotificationModel notification = NotificationModel(NotificationType.ServerWipes);
    notification.notification_type = NotificationType.ServerWipes;
    notification.server = value.selected_server;
    context.read<NotificationsProvider>().add(notification);
    Navigator.pop(context);
  }
}
