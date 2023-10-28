import 'dart:async';

import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/assistants/black_theme_google_map.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/push_notifications/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  GoogleMapController? newGoogleMapController;
  //here we have created the instance of the GoogleMapController
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // Position? driverCurrentPosition;
  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;

  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  // blackThemeGoogleMap() {
  //   newGoogleMapController!.setMapStyle('''
  //                   [
  //                     {
  //                       "elementType": "geometry",
  //                       "stylers": [
  //                         {
  //                           "color": "#242f3e"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "elementType": "labels.text.fill",
  //                       "stylers": [
  //                         {
  //                           "color": "#746855"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "elementType": "labels.text.stroke",
  //                       "stylers": [
  //                         {
  //                           "color": "#242f3e"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "administrative.locality",
  //                       "elementType": "labels.text.fill",
  //                       "stylers": [
  //                         {
  //                           "color": "#d59563"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "poi",
  //                       "elementType": "labels.text.fill",
  //                       "stylers": [
  //                         {
  //                           "color": "#d59563"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "poi.park",
  //                       "elementType": "geometry",
  //                       "stylers": [
  //                         {
  //                           "color": "#263c3f"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "poi.park",
  //                       "elementType": "labels.text.fill",
  //                       "stylers": [
  //                         {
  //                           "color": "#6b9a76"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "road",
  //                       "elementType": "geometry",
  //                       "stylers": [
  //                         {
  //                           "color": "#38414e"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "road",
  //                       "elementType": "geometry.stroke",
  //                       "stylers": [
  //                         {
  //                           "color": "#212a37"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "road",
  //                       "elementType": "labels.text.fill",
  //                       "stylers": [
  //                         {
  //                           "color": "#9ca5b3"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "road.highway",
  //                       "elementType": "geometry",
  //                       "stylers": [
  //                         {
  //                           "color": "#746855"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "road.highway",
  //                       "elementType": "geometry.stroke",
  //                       "stylers": [
  //                         {
  //                           "color": "#1f2835"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "road.highway",
  //                       "elementType": "labels.text.fill",
  //                       "stylers": [
  //                         {
  //                           "color": "#f3d19c"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "transit",
  //                       "elementType": "geometry",
  //                       "stylers": [
  //                         {
  //                           "color": "#2f3948"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "transit.station",
  //                       "elementType": "labels.text.fill",
  //                       "stylers": [
  //                         {
  //                           "color": "#d59563"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "water",
  //                       "elementType": "geometry",
  //                       "stylers": [
  //                         {
  //                           "color": "#17263c"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "water",
  //                       "elementType": "labels.text.fill",
  //                       "stylers": [
  //                         {
  //                           "color": "#515c6d"
  //                         }
  //                       ]
  //                     },
  //                     {
  //                       "featureType": "water",
  //                       "elementType": "labels.text.stroke",
  //                       "stylers": [
  //                         {
  //                           "color": "#17263c"
  //                         }
  //                       ]
  //                     }
  //                   ]
  //               ''');
  // }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator
        .requestPermission(); //it will request the locationPermission that hey allow the permission

    //if user denied the permission to turn on the location of the phone. Then we again request the user to turn on the location
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator
          .requestPermission(); //it will request the locationPermission that hey allow the permission
    }
  }

  locateDriverPosition() async {
    //the below code will give us the position of the current user at the real time
    Position cPosition = await Geolocator.getCurrentPosition(
        // desiredAccuracy: geolocator.LocationAccuracy.high);
        desiredAccuracy: LocationAccuracy
            .high); //we used high here bcz we want the exact accurate location of the user
    // userCurrentPosition = cPosition;
    if (cPosition != null) {
      print("User position: ${cPosition.latitude}, ${cPosition.longitude}");
      // Update the user's position
      setState(() {
        driverCurrentPosition = cPosition;
      });
    } else {
      print("Failed to get user's position.");
    }

    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //we have implemented the reverse geocoding here i.e. we have converted the address in the terms of the coordinates to the human readable address.

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoOrdinates(
            driverCurrentPosition!,
            context); //we passed the position i.e. the coordinates to the method. This method is defined in the assistant_methods.dart file
    print("this is your Address = " + humanReadableAddress);
  }

  readCurrentDriverInformation() async {
    currentFirebaseUser = fAuth.currentUser;

    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        onlineDriverData.id = (snap.snapshot.value as Map)["id"];
        onlineDriverData.name = (snap.snapshot.value as Map)["name"];
        onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDriverData.email = (snap.snapshot.value as Map)["email"];
      }
    });

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMassaging(context);
    pushNotificationSystem.generateAndGetToken();
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    // AssistantMethods.readCurrentOnlineUserInfo();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            //black theme for the google map
            blackThemeGoogleMap(newGoogleMapController);

            locateDriverPosition();
          },
        ),

        //ui for online offline mechanics
        statusText != "Now Online"
            //this container will be displayed when the mechanic is offline
            ? Container(
                height: MediaQuery.of(context)
                    .size
                    .height, //height of the contianer will be equal to the height of the mobile phone
                width: double.infinity,
                color: Colors.black87,
              )

            //this container will be displayed when the mechanic is offline
            : Container(),

        //button for online offline mechanic
        Positioned(
          top: statusText != "Now Online"
              ? MediaQuery.of(context).size.height *
                  0.46 //46% of the height when offline
              : 25,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (isDriverActive != true)
                  //driver is offline. Therefore we have to make the driver online now
                  {
                    driverIsOnlineNow();
                    updateDriversLocationAtRealTime();

                    setState(() {
                      statusText = "Now Online";
                      isDriverActive = true;
                      buttonColor = Colors.transparent;
                    });

                    // display Toast
                    Fluttertoast.showToast(msg: "You are Online Now");
                  }
                  //else if the driver is already online then make the driver offline
                  else {
                    driverIsOfflineNow();

                    setState(() {
                      statusText = "Now Offline";
                      isDriverActive = false;
                      buttonColor = Colors.grey;
                    });

                    // display Toast
                    Fluttertoast.showToast(msg: "You are Offline Now");
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: buttonColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18), //width of the button = 18
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: statusText != "Now Online"
                    ? Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.phonelink_ring,
                        color: Colors.white,
                        size: 26,
                      ),
              ),
            ],
          ),
        ) //we have used positioned widget here bcz when the driver is offline we will display the offline button here and when mechanic will click the button the mechanic will become online and when the mechanic become online then we will display the online button at the top
      ],
    );
  }

  //we will call this method when the driver will click on the button 'Now Offline' and by using this method we will make the driver online.
  driverIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    driverCurrentPosition = pos;

    Geofire.initialize("activeDrivers");

    Geofire.setLocation(currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        //this 'drivers' in the parent collection from which we are going to choose/select the online drivers by using the 'currentFirebaseUser!.uid'
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    //this is used to check whether currently the driver is assigned to some customer or is free/idle.

    ref.set("idle");
    //driver is initially idle i.e. he can accept the request from any user
    ref.onValue.listen((event) {});
    //this is used bcz the driver listen to the request of any user who request's him for the service
  }

  updateDriversLocationAtRealTime() {
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition =
          position; //when the driver is moving then we can get the live location of the driver using thiss

      if (isDriverActive ==
          true) //if driver is online. We have created the 'isDriverActive' boolean type of the variable above
      {
        Geofire.setLocation(currentFirebaseUser!.uid,
            driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      }

      LatLng latLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
      //here we are animating the camera with the changed position of the drivers
    });
  }

  driverIsOfflineNow() {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        //this 'drivers' in the parent collection from which we are going to choose/select the online drivers by using the 'currentFirebaseUser!.uid'
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");

    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(const Duration(milliseconds: 2000), () {
      //we can also write :- SystemNavigator.pop(); instead of the below line
      // SystemChannels.platform.invokeMethod(
      //     "SystemNavigator.pop"); //by this we are refreshing the state of the app
      SystemNavigator.pop(); //by this we are refreshing the state of the app
    });
  }
}
