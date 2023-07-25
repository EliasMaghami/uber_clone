import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
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
  String distance = "Calculating the distance";
  String originAddress = "Address Origin:";
  String destinationAddress = "Address destination:";
  List<GeoPoint> geoPoint = [];

  List currentWidgetList = [CurrentWidgetStates.stateSelectOrigin];

  Widget markerIcon = SvgPicture.asset(
    Assets.icons.origin,
    height: 100,
    width: 50,
  );
  Widget originMarker = SvgPicture.asset(
    Assets.icons.origin,
    height: 100,
    width: 50,
  );
  Widget destinationMarker = SvgPicture.asset(
    Assets.icons.destination,
    height: 100,
    width: 50,
  );

  MapController mapController = MapController(
    initMapWithUserPosition:
        const UserTrackingOption(enableTracking: true, unFollowUser: false),
    // initPosition: GeoPoint(
    //   latitude: 38.749976,
    //   longitude: 30.546327,
    // ),
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
                    enableTracking: true, unFollowUser: true),
                initZoom: 15,
                isPicker: true,
                mapIsLoading: const SpinKitCircle(color: Colors.indigoAccent),
                minZoomLevel: 8,
                maxZoomLevel: 18,
                stepZoom: 1,
                markerOption: MarkerOption(
                    advancedPickerMarker: MarkerIcon(
                  iconWidget: markerIcon,
                )),
              ),
            ),

            //currentWidget
            currentWidget(),
            MyBackButton(
              onPressed: () {
                switch (currentWidgetList.last) {
                  case CurrentWidgetStates.stateSelectOrigin:
                    break;
                  case CurrentWidgetStates.stateSelectDestination:
                    geoPoint.removeLast();
                    markerIcon = originMarker;

                    break;
                  case CurrentWidgetStates.stateRequestDriver:
                    mapController.advancedPositionPicker();
                    mapController.removeMarker(geoPoint.last);
                    geoPoint.removeLast();
                    markerIcon = destinationMarker;

                    break;
                  default:
                }
                setState(() {
                  currentWidgetList.removeLast();
                });
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

  Widget origin() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
          onPressed: (() async {
            GeoPoint originGeoPoint =
                await mapController.getCurrentPositionAdvancedPositionPicker();

            log("latitude:${originGeoPoint.latitude}\n longitude:${originGeoPoint.longitude}");
            geoPoint.add(originGeoPoint);
            markerIcon = destinationMarker;
            setState(() {
              currentWidgetList.add(CurrentWidgetStates.stateSelectDestination);
            });

            mapController.init();
          }),
          child: Text('Select the origin', style: MyTextStyles.button),
        ),
      ),
    );
  }

  Widget destination() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
          onPressed: (() async {
            await mapController
                .getCurrentPositionAdvancedPositionPicker()
                .then((value) {
              geoPoint.add(value);
            });

            mapController.cancelAdvancedPositionPicker();

            await mapController.addMarker(geoPoint.first,
                markerIcon: MarkerIcon(
                  iconWidget: originMarker,
                ));
            await mapController.addMarker(geoPoint.last,
                markerIcon: MarkerIcon(
                  iconWidget: destinationMarker,
                ));
            setState(() {
              currentWidgetList.add(CurrentWidgetStates.stateRequestDriver);
            });

            await distance2point(geoPoint.first, geoPoint.last).then((value) {
              setState(() {
                if (value <= 1000) {
                  distance =
                      "Distance from origin to destination${value.toInt()} m";
                } else {
                  distance =
                      "Distance from origin to destination${value ~/ 1000} Km";
                }
              });
            });
            getAddress();
          }),
          child: Text('Select the destination', style: MyTextStyles.button),
        ),
      ),
    );
  }

  Widget requestDriver() {
    getCurrentTag();
    mapController.zoomOut();
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.medium),
                color: Colors.pinkAccent,
              ),
              child: Center(child: Text(distance)),
            ),
            const SizedBox(
              height: Dimens.small,
            ),
            Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.medium),
                color: Colors.pinkAccent,
              ),
              child: Center(child: Text("originAddress :${originAddress}")),
            ),
            const SizedBox(
              height: Dimens.small,
            ),
            Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimens.medium),
                color: Colors.pinkAccent,
              ),
              child: Center(
                  child: Text("destinationAddress :${destinationAddress}")),
            ),
            const SizedBox(
              height: Dimens.small,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (() {}),
                child: Text('Driver Request', style: MyTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getAddress() async {
    try {
      await placemarkFromCoordinates(
              geoPoint.last.latitude, geoPoint.last.longitude)
          .then((List<Placemark> placeMarkList) {
        setState(() {
          destinationAddress =
              "${placeMarkList.first.locality}${placeMarkList.first.thoroughfare}${placeMarkList[2].name}";
        });
      });
      await placemarkFromCoordinates(
              geoPoint.first.latitude, geoPoint.first.longitude)
          .then((List<Placemark> placeMarkList) {
        setState(() {
          originAddress =
              "${placeMarkList.first.locality}${placeMarkList.first.thoroughfare}${placeMarkList[2].name}";
        });
      });
    } catch (e) {
      originAddress = "Address not found";
      destinationAddress = "Address not found";
    }
  }
}
