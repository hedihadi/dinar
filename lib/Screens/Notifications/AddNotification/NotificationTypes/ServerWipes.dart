
import 'package:RustCompanion/Providers/NotificationsProvider.dart';
import 'package:RustCompanion/Screens/Notifications/AddNotification/SelectServer.dart';
import 'package:RustCompanion/utils/ColorManager.dart';
import 'package:RustCompanion/utils/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';

class ServerWipes extends StatefulWidget {
  const ServerWipes({Key? key}) : super(key: key);

  @override
  State<ServerWipes> createState() => _ServerWipesState();
}

class _ServerWipesState extends State<ServerWipes> {
  Server? selected_server = null;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        SizedBox(height: 5.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: ElevatedButton(
            onPressed: () async {
              Server? server = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SelectServer()),
              );
              if (server != null) {
                setState(() {
                  selected_server = server;
                });
              }
            },
            child: Text("Select A Server"),
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(ColorManager().background1)),
          ),
        ),
        selected_server == null
            ? Container()
            : RichText(
                textAlign: TextAlign.center,
                text: new TextSpan(
                  style: new TextStyle(
                    fontSize: 11.sp,
                  ),
                  children: <TextSpan>[
                    new TextSpan(text: "You'll get a Notification when "),
                    new TextSpan(text: '${selected_server!.name}', style: new TextStyle(color: Colors.amber, fontSize: 13.sp)),
                    new TextSpan(text: " Wipes!"),
                  ],
                ),
              ),
        SizedBox(height: 2.h),
        selected_server == null
            ? Container()
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: ElevatedButton(
                  onPressed: () async {
                    NotificationModel notification = NotificationModel(NotificationType.ServerWipes);
                    notification.notification_type = NotificationType.ServerWipes;
                    notification.server = selected_server;
                    context.read<NotificationsProvider>().add(notification);
                    Navigator.pop(context);
                  },
                  child: Text("Add Notification"),
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange[700])),
                ),
              ),
      ],
    );
  }
}
