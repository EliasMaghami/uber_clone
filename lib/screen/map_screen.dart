import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snap_simple/constant/dimens.dart';
import 'package:snap_simple/gen/assets.gen.dart';
import 'package:snap_simple/widget/back_button.dart';
import '../constant/text_styl.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class CurrentWidgetStates {
  CurrentWidgetStates._();
  static const stateSelectOrigin = 0;
  static const stateSelectDestination = 1;
  static const stateRequestDriver = 2;
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController(
      initMapWithUserPosition:
          UserTrackingOption(enableTracking: true, unFollowUser: false),
      //  const UserTrackingOption.withoutUserPosition(enableTracking: false,unFollowUser: false),
      initPosition: GeoPoint(
        latitude: 38.749976,
        longitude: 30.546327,
      ));

  List<GeoPoint> geoPoint = [];

  List currentWidgetList = [CurrentWidgetStates.stateSelectOrigin];

  Widget markerIcon = SvgPicture.asset(
    Assets.icons.origin,
    height: 100,
    width: 40,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            //osm map
            SizedBox.expand(
              child: OSMFlutter(
                controller: mapController,
                userTrackingOption: const UserTrackingOption(
                    enableTracking: false, unFollowUser: false),
                initZoom: 15,
                isPicker: true,
                mapIsLoading: const SpinKitCircle(color: Colors.indigoAccent),
                minZoomLevel: 8,
                maxZoomLevel: 18,
                stepZoom: 1,
              ),
            ),

            // Container(
            //   color: Colors.pink,
            // ),

            //currentWidget
            currentWidget(),
            MyBackButton(
              onPressed: () {
                if (currentWidgetList.length > 1) {
                  setState(() {
                    currentWidgetList.removeLast();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget currentWidget() {
    Widget widget = origin();
    switch (currentWidgetList.last) {
      case CurrentWidgetStates.stateSelectOrigin:
        widget = origin();
        break;

      case CurrentWidgetStates.stateSelectDestination:
        widget = destination();
        break;

      case CurrentWidgetStates.stateRequestDriver:
        widget = requestDriver();
        break;
    }
    return widget;
  }

  Positioned origin() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
          onPressed: (() {
            setState(() {
              currentWidgetList.add(CurrentWidgetStates.stateSelectDestination);
            });
          }),
          child: Text('Select the origin', style: MyTextStyles.button),
        ),
      ),
    );
  }

  Positioned destination() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
          onPressed: (() {
            setState(() {
              currentWidgetList.add(CurrentWidgetStates.stateRequestDriver);
            });
          }),
          child: Text('Select the destination', style: MyTextStyles.button),
        ),
      ),
    );
  }

  Positioned requestDriver() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
          onPressed: (() {}),
          child: Text('Driver Request', style: MyTextStyles.button),
        ),
      ),
    );
  }
}
