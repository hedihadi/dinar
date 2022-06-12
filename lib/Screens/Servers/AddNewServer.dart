import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:RustCompanion/Providers/SearchServersProvider.dart';
import 'package:RustCompanion/Providers/ServersProvider.dart';
import 'package:RustCompanion/Screens/Servers/MyServer.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart' as intll;
import 'package:http/http.dart' as http;
import 'package:RustCompanion/Functions/ApiManager.dart';
import 'package:RustCompanion/utils/ColorManager.dart';
import 'package:RustCompanion/utils/models.dart';
import 'package:RustCompanion/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as dartio;
import 'package:google_mobile_ads/google_mobile_ads.dart' as ad;
import 'package:function_tree/function_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AddNewServer extends StatefulWidget {
  const AddNewServer({Key? key}) : super(key: key);

  @override
  State<AddNewServer> createState() => AddNewServerState();
}

class AddNewServerState extends State<AddNewServer> {
  TextEditingController search_controller = TextEditingController();
  TextEditingController minimum_controller = TextEditingController(text: "1");
  TextEditingController maximum_controller = TextEditingController(text: "999");
  bool descending = true;
  bool hide_non_wiping_servers = true;
  SortBy sort_by = SortBy.Players;
  final ApiManager api_manager = ApiManager();
  ScrollController scroll_controller = ScrollController();
  List<Server> servers = [];
  Map<ServerType, bool> server_types = {ServerType.official: true, ServerType.community: true, ServerType.modded: true};
  Map<WipeType, bool> wipe_types = {WipeType.weekly: true, WipeType.biweekly: true, WipeType.monthly: true};
  Key list_key = Key("1");
  bool loading = false;
  int key = 0;
  StreamController<ServerSearchResponse> controller = StreamController<ServerSearchResponse>.broadcast();
  get_key() {
    return key;
  }

  @override
  void initState() {
    super.initState();
    controller.stream.listen((event) {
      if (event.key == key) {
        if (mounted) {
          context.read<SearchServersProvider>().addServers(event.servers!);
        }
        context.read<SearchServersProvider>().sort_servers(sort_by, descending, hide_non_wiping_servers);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<SearchServersProvider>().clear();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
            elevation: 0, backgroundColor: HexColor("#202020"), centerTitle: true, title: Text("Add New Server", overflow: TextOverflow.ellipsis)),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.w),
            child: CustomScrollView(
              slivers: [
                SliverList(
                    delegate: SliverChildListDelegate([
                  SizedBox(height: 2.h),
                  TextField(
                    controller: search_controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3.sp),
                          borderSide: BorderSide.none,
                        ),
                        labelStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: ColorManager().background1,
                        labelText: "Search server name...",
                        floatingLabelBehavior: FloatingLabelBehavior.never),
                  ),
                  Divider(height: 2.h),
                  ServerTypesWidget(),
                  Divider(height: 2.h),
                  Text(
                    "Players:-",
                    style: TextStyle(fontFamily: "BebasNeue", fontSize: 15.sp, color: ColorManager().favorited),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: minimum_controller,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.sp),
                                borderSide: BorderSide.none,
                              ),
                              labelStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: ColorManager().background1,
                              labelText: "Minimum",
                              floatingLabelBehavior: FloatingLabelBehavior.never),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Flexible(
                        child: TextField(
                          controller: maximum_controller,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.sp),
                                borderSide: BorderSide.none,
                              ),
                              labelStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: ColorManager().background1,
                              labelText: "Maximum",
                              floatingLabelBehavior: FloatingLabelBehavior.never),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 2.h),
                  SortByWidget(),
                  Divider(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: ElevatedButton(
                      onPressed: () async {
                        //check if it's loading, if so, stop the search
                        if (loading == true) {
                          setState(() {
                            loading = false;
                            key = Random().nextInt(999999);
                          });
                          return;
                        } else {}
                        setState(() {
                          loading = true;
                        });
                        key = Random().nextInt(999999);
                        context.read<SearchServersProvider>().clear();

                        if (search_controller.text == "") {
                          //keep track of the current key
                          int _key = key;
                          final favorited_servers = context.read<ServersProvider>().favorited_servers;

                          await api_manager.getAllServers(favorited_servers, key, controller, this, server_types, wipe_types,
                              int.parse(minimum_controller.text), int.parse(maximum_controller.text));
                          //if key has changed, that means this is irrelevant now, dont change loading state.
                          if (_key == key) {
                            setState(() {
                              loading = false;
                            });
                          }
                        }
                        int _key = key;

                        await api_manager.searchServers(search_controller.text, server_types, wipe_types, int.parse(minimum_controller.text),
                            int.parse(maximum_controller.text), key, controller, context);
                        if (_key == key) {
                          setState(() {
                            loading = false;
                          });
                        }
                      },
                      child: loading
                          ? SizedBox(child: CircularProgressIndicator(), height: 2.h)
                          : Text(
                              "Search",
                              style: TextStyle(color: ColorManager().background1),
                            ),
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(ColorManager().accent)),
                    ),
                  ),
                  Consumer<SearchServersProvider>(builder: (context1, value, child) {
                    return value.servers.length == 0
                        ? Container()
                        : Text(
                            'loaded ${value.filtered_servers.length} servers.',
                            style: TextStyle(color: ColorManager().accent, fontFamily: "BebasNeue", fontSize: 15.sp),
                            textAlign: TextAlign.center,
                          );
                  }),
                ])),
                Consumer<SearchServersProvider>(builder: (context1, value, child) {
                  return SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) => MyServer(server: value.filtered_servers[index], enable_animation: false),
                    childCount: value.filtered_servers.length,
                  ));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget ServerTypesWidget() {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Text(
          "Server Type:-",
          style: TextStyle(fontFamily: "BebasNeue", fontSize: 15.sp, color: ColorManager().favorited),
        ),
        Row(
          children: [
            Row(
              children: [
                Checkbox(
                  checkColor: ColorManager().favorited,
                  fillColor: MaterialStateProperty.all(ColorManager().accent),
                  value: server_types[ServerType.official],
                  onChanged: (bool? value) {
                    setState(() {
                      server_types[ServerType.official] = !server_types[ServerType.official]!;
                    });
                  },
                ),
                Text(
                  'Official',
                  style: TextStyle(color: ColorManager().accent, fontFamily: "BebasNeue", fontSize: 15.sp),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  checkColor: ColorManager().favorited,
                  fillColor: MaterialStateProperty.all(ColorManager().accent),
                  value: server_types[ServerType.community],
                  onChanged: (bool? value) {
                    setState(() {
                      server_types[ServerType.community] = !server_types[ServerType.community]!;
                    });
                  },
                ),
                Text(
                  'Community',
                  style: TextStyle(color: ColorManager().accent, fontFamily: "BebasNeue", fontSize: 15.sp),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  checkColor: ColorManager().favorited,
                  fillColor: MaterialStateProperty.all(ColorManager().accent),
                  value: server_types[ServerType.modded],
                  onChanged: (bool? value) {
                    setState(() {
                      server_types[ServerType.modded] = !server_types[ServerType.modded]!;
                    });
                  },
                ),
                Text(
                  'Modded',
                  style: TextStyle(color: ColorManager().accent, fontFamily: "BebasNeue", fontSize: 15.sp),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Row(
              children: [
                Checkbox(
                  checkColor: ColorManager().favorited,
                  fillColor: MaterialStateProperty.all(ColorManager().accent),
                  value: wipe_types[WipeType.weekly],
                  onChanged: (bool? value) {
                    setState(() {
                      wipe_types[WipeType.weekly] = !wipe_types[WipeType.weekly]!;
                    });
                  },
                ),
                Text(
                  'Weekly',
                  style: TextStyle(color: ColorManager().accent, fontFamily: "BebasNeue", fontSize: 15.sp),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  checkColor: ColorManager().favorited,
                  fillColor: MaterialStateProperty.all(ColorManager().accent),
                  value: wipe_types[WipeType.biweekly],
                  onChanged: (bool? value) {
                    setState(() {
                      wipe_types[WipeType.biweekly] = !wipe_types[WipeType.biweekly]!;
                    });
                  },
                ),
                Text(
                  'BiWeekly',
                  style: TextStyle(color: ColorManager().accent, fontFamily: "BebasNeue", fontSize: 15.sp),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  checkColor: ColorManager().favorited,
                  fillColor: MaterialStateProperty.all(ColorManager().accent),
                  value: wipe_types[WipeType.monthly],
                  onChanged: (bool? value) {
                    setState(() {
                      wipe_types[WipeType.monthly] = !wipe_types[WipeType.monthly]!;
                    });
                  },
                ),
                Text(
                  'Monthly',
                  style: TextStyle(color: ColorManager().accent, fontFamily: "BebasNeue", fontSize: 15.sp),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget SortByWidget() {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Text(
          "Sort By:-",
          style: TextStyle(fontFamily: "BebasNeue", fontSize: 15.sp, color: ColorManager().favorited),
        ),
        Row(
          children: [
            DropdownButton<SortBy>(
              value: sort_by,
              style: TextStyle(color: ColorManager().accent),
              underline: Container(
                height: 2,
                color: ColorManager().accent,
              ),
              onChanged: (SortBy? newValue) {
                setState(() {
                  sort_by = newValue!;
                });
                context.read<SearchServersProvider>().sort_servers(sort_by, descending, hide_non_wiping_servers);
              },
              items: SortBy.values.map<DropdownMenuItem<SortBy>>((SortBy value) {
                return DropdownMenuItem<SortBy>(
                  value: value,
                  child: Text(
                    value.toString().replaceAll("SortBy.", ""),
                    style: TextStyle(color: ColorManager().accent),
                  ),
                );
              }).toList(),
            ),
            Row(
              children: [
                Checkbox(
                  checkColor: ColorManager().favorited,
                  fillColor: MaterialStateProperty.all(ColorManager().accent),
                  value: descending,
                  onChanged: (bool? value) {
                    setState(() {
                      descending = !descending;
                    });
                    context.read<SearchServersProvider>().sort_servers(sort_by, descending, hide_non_wiping_servers);
                  },
                ),
                Text(
                  'Descending',
                  style: TextStyle(color: ColorManager().accent, fontFamily: "BebasNeue", fontSize: 15.sp),
                ),
              ],
            ),
          ],
        ),
        Divider(),
        Row(
          children: [
            Checkbox(
              checkColor: ColorManager().favorited,
              fillColor: MaterialStateProperty.all(ColorManager().accent),
              value: hide_non_wiping_servers,
              onChanged: (bool? value) {
                setState(() {
                  hide_non_wiping_servers = !hide_non_wiping_servers;
                });
                context.read<SearchServersProvider>().sort_servers(sort_by, descending, hide_non_wiping_servers);
              },
            ),
            Text(
              'hide non-wiping servers',
              style: TextStyle(color: ColorManager().accent, fontFamily: "BebasNeue", fontSize: 15.sp),
            ),
          ],
        ),
      ],
    );
  }
}
