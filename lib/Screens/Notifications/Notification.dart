import 'package:RustCompanion/utils/ColorManager.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:RustCompanion/Providers/NotificationsProvider.dart';
import 'package:RustCompanion/Providers/RefreshServersProvider.dart';
import 'package:RustCompanion/Providers/ServersProvider.dart';
import 'package:RustCompanion/Screens/Notifications/Notification.dart';
import 'package:RustCompanion/Screens/Servers/MyServer.dart';
import 'package:RustCompanion/Screens/Servers/ServerInfo.dart';
import 'package:RustCompanion/utils/models.dart';
import 'package:RustCompanion/utils/utils.dart';
import 'package:sizer/sizer.dart';

class NotificationWidget extends StatefulWidget {
  NotificationWidget({Key? key, required this.notification}) : super(key: key);
  NotificationModel notification;

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: Container(
        decoration: BoxDecoration(
            color: widget.notification.color,
            border: Border.all(
              color: widget.notification.color!,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        padding: EdgeInsets.all(10.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${widget.notification.notification_type.notificationTypeToReadable()}",
                  style: TextStyle(color: ColorManager().background, fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    color: Colors.red[400],
                    icon: Icon(Icons.highlight_remove),
                    onPressed: () {
                      context.read<NotificationsProvider>().remove(widget.notification.id!);
                    },
                  ),
                )
              ],
            ),
            SizedBox(height: 1.h),
            widget.notification.player == null
                ? Container()
                : Row(
                    children: [
                      tag(" ${widget.notification.player!.name.characters.length > 30 ? '${widget.notification.server!.name.characters.take(30)}...' : '${widget.notification.player!.name}'}",
                          Icon(FontAwesomeIcons.user)),
                    ],
                  ),
            SizedBox(height: 1.h),
            widget.notification.server == null
                ? Container()
                : Row(
                    children: [
                      tag("${widget.notification.server!.name.characters.length > 30 ? '${widget.notification.server!.name.characters.take(30)}...' : '${widget.notification.server!.name}'}",
                          Icon(FontAwesomeIcons.server)),
                    ],
                  ),
            widget.notification.server == null
                ? Container()
                : ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ServerInfo(server: widget.notification.server!)),
                      );
                    },
                    child: Text("Show Server"),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(HexColor("#303030"))),
                  ),
          ],
        ),
      ),
    );
  }
}
