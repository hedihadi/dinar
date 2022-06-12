import 'package:RustCompanion/Functions/ApiManager.dart';
import 'package:RustCompanion/Providers/AddNewNotificationProvider.dart';
import 'package:RustCompanion/Providers/NotificationsProvider.dart';
import 'package:RustCompanion/Providers/PlayersProvider.dart';
import 'package:RustCompanion/Providers/ServersProvider.dart';
import 'package:RustCompanion/Screens/Notifications/AddNotification/AddNotification_PlayerWidget.dart';
import 'package:RustCompanion/Screens/Notifications/AddNotification/SelectServer.dart';
import 'package:RustCompanion/Screens/Notifications/AddNotification/AddNotification_ServerWidget.dart';
import 'package:RustCompanion/utils/ColorManager.dart';
import 'package:RustCompanion/utils/models.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';

class PlayerLeaveJoinServer extends StatefulWidget {
  PlayerLeaveJoinServer({Key? key, required this.player_leave_or_join}) : super(key: key);
  PlayerLeaveOrJoin player_leave_or_join;

  @override
  State<PlayerLeaveJoinServer> createState() => _ServerWipesState();
}

class _ServerWipesState extends State<PlayerLeaveJoinServer> {
  RewardedAd? ad;
  @override
  void initState() {
    super.initState();
    RewardedAd.load(
        request: AdRequest(),
        adUnitId: 'ca-app-pub-3008670047597964/8132914304',
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
            "Select A Player",
            style: TextStyle(color: ColorManager().minor),
          ),
          children: [
            Container(
              color: ColorManager().background1,
              height: 40.h,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: context.read<PlayersProvider>().players.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(10.sp),
                      child: PlayerComesOnline_PlayerWidget(player: context.read<PlayersProvider>().players[index]),
                    );
                  }),
            ),
          ],
        ),
        SizedBox(height: 1.h),
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
        SizedBox(height: 1.h),
        Consumer<AddNewNotificationProvider>(builder: (context1, value, child) {
          return ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              (value.selected_player == null || value.selected_server == null)
                  ? Container()
                  : RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                        style: new TextStyle(
                          fontSize: 11.sp,
                        ),
                        children: <TextSpan>[
                          new TextSpan(text: "You'll get a Notification when "),
                          new TextSpan(
                              text: '${value.selected_player!.name}', style: new TextStyle(color: ColorManager().favorited, fontSize: 11.sp)),
                          widget.player_leave_or_join == PlayerLeaveOrJoin.Join ? new TextSpan(text: " Joins ") : new TextSpan(text: " Leaves "),
                          new TextSpan(
                              text: '${value.selected_server!.name}', style: new TextStyle(color: ColorManager().favorited, fontSize: 11.sp)),
                        ],
                      ),
                    ),
              SizedBox(height: 2.h),
              (value.selected_player == null || value.selected_server == null)
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: ElevatedButton(
                        onPressed: () async {
                          ad?.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) async {
                                setNotification(value);
                              }) ??
                              setNotification(value);
                        },
                        child: Text("Add Notification"),
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(ColorManager().accent)),
                      ),
                    ),
            ],
          );
        }),
      ],
    );
  }

  setNotification(value) async {
    NotificationModel notification = widget.player_leave_or_join == PlayerLeaveOrJoin.Join
        ? NotificationModel(NotificationType.PlayerJoinServer)
        : NotificationModel(NotificationType.PlayerLeaveServer);
    final new_player_info = await ApiManager().getPlayerInfo(value.selected_player!.id);
    notification.player = new_player_info;
    notification.server = value.selected_server;
    if (new_player_info == null) {}
    context.read<NotificationsProvider>().add(notification);
    Navigator.pop(context);
  }
}
