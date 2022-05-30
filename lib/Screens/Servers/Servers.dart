import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:RustCompanion/Providers/RefreshServersProvider.dart';
import 'package:RustCompanion/Providers/ServersProvider.dart';
import 'package:RustCompanion/Screens/Servers/MyServer.dart';

class Servers extends StatefulWidget {
  const Servers({Key? key}) : super(key: key);

  @override
  State<Servers> createState() => _MyServersState();
}

class _MyServersState extends State<Servers> {
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
    return Consumer<ServersProvider>(builder: (context1, value, child) {
      return SmartRefresher(
        controller: refresh_controller,
        enablePullDown: true,
        header: WaterDropMaterialHeader(),
        onRefresh: () async {
          context1.read<RefreshServersProvider>().update();
          Future.delayed(const Duration(seconds: 1), () {
            refresh_controller.refreshToIdle();
          });
        },
        child: ListView.separated(
            shrinkWrap: true,
            itemCount: value.servers.length,
            separatorBuilder: (context, position) {
              return position == 0 ? Container(height: myBanner.size.height.toDouble(), child: adWidget) : Container();
            },
            itemBuilder: (context1, index) {
              return MyServer(server: value.servers[index]);
            }),
      );
    });
  }
}
