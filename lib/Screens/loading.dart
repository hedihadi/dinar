import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:dinar/Functions/colors.dart';
import 'package:dinar/Functions/data.dart';
import 'package:dinar/Functions/database_manager.dart';
import 'package:dinar/Functions/models.dart';
import 'package:dinar/Functions/utils.dart';
import 'package:dinar/Providers/localization_provider.dart';
import 'package:dinar/Screens/main_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart' as intll;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io' as dartio;
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:function_tree/function_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Loading extends StatefulWidget {
  Loading({Key? key}) : super(key: key);
  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  InitializeResponseType response_type = InitializeResponseType.loading;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    response_type = await DatabaseManager().initialize(context);

    setState(() {});
//check if user has internet
    if ([InitializeResponseType.no_internet, InitializeResponseType.success_no_internet].contains(response_type)) {
      //user have no internet, no need to retrieve userdata.
    } else {
      //user has internet, let's retrieve userdata
      getUserData();
    }
  }

  Future<void> getUserData() async {
    //now get device info for debugging
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    GetIt.instance<Data>().android_version = androidInfo.version.release;
    GetIt.instance<Data>().sdk_version = androidInfo.version.sdkInt.toString();
    GetIt.instance<Data>().manufacturer = androidInfo.manufacturer;

    try {
      dynamic result = await http.get(Uri.parse("https://ipinfo.io/?token=c83ecbc5ddd470"));
      result = jsonDecode(result.body);
      GetIt.instance<Data>().region = result["region"];
      GetIt.instance<Data>().ip = result["ip"];
      GetIt.instance<Data>().org = result["org"];
      GetIt.instance<Data>().country = result["country"];
    } on Exception catch (c) {
      //if an error occured, send the error to analytics so we know what was it.
      await FirebaseAnalytics.instance.logEvent(name: 'error_getting_userdata', parameters: {
        "error": c.toString(),
        "android_version": GetIt.instance<Data>().android_version,
        "sdk_version": GetIt.instance<Data>().sdk_version,
        "manufactorer": GetIt.instance<Data>().manufacturer
      });
    }
    //no error has occured, send data to analytics
    await FirebaseAnalytics.instance.logEvent(name: 'app_initialized', parameters: {
      "android_version": GetIt.instance<Data>().android_version,
      "sdk_version": GetIt.instance<Data>().sdk_version,
      "manufactorer": GetIt.instance<Data>().manufacturer,
      "region": GetIt.instance<Data>().region,
      "ip": GetIt.instance<Data>().ip,
      "org": GetIt.instance<Data>().org,
      "country": GetIt.instance<Data>().country,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, value, child) {
        return Scaffold(
          body: Builder(
            builder: (context) {
              if (response_type == InitializeResponseType.loading) {
                return Center(child: CircularProgressIndicator());
              } else if (response_type == InitializeResponseType.no_internet) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "an error occured, please make sure you have internet connection.".localize(context),
                        style: TextStyle(fontSize: 10.sp, color: mainTextColor1),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.h),
                      CircleAvatar(
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                response_type = InitializeResponseType.loading;
                              });
                              initialize();
                            },
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.white,
                            )),
                        backgroundColor: Colors.red,
                      )
                    ],
                  ),
                );
              } else {
                return Directionality(textDirection: value.language == "english" ? TextDirection.ltr : TextDirection.rtl, child: MainScreen());
              }
            },
          ),
        );
      },
    );
  }
}
