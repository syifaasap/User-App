import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_app/Assists/assists_method.dart';
import 'package:user_app/Assists/geofire_assist.dart';
import 'package:user_app/InfoHandler/info_handler_app.dart';
import 'package:user_app/Models/active_nearby_available_technicians.dart';
// import 'package:user_app/Models/directions_details.dart';
import 'package:user_app/Widgets/nav_drawer.dart';
import 'package:user_app/Widgets/pay_fare_amount.dart';
import 'package:user_app/Widgets/progress_dialog.dart';
import 'package:user_app/rate_technician_screen.dart';
import 'package:user_app/search_places_screen.dart';
import 'package:user_app/select_active_technician.dart';
import 'Global/global.dart';

class MyMainScreen extends StatefulWidget {
  const MyMainScreen({super.key});

  @override
  State<MyMainScreen> createState() {
    return _MyMainScreenState();
  }
}

class _MyMainScreenState extends State<MyMainScreen> {
  final Completer<GoogleMapController> _controllerMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 200;
  double waitingResponseFromTechnicianContainerHeight = 0;
  double assignedTechnicianInfoContainerHeight = 0;

// Menambahkan Geolocator
  Position? userCurrentPosition;
  var geoLocator = Geolocator();

// Notifikasi izin lokasi
  LocationPermission? _locationPermission;

// Menambahkan credit Google
  double bottomPaddingMap = 0;

// Membuat Polyline
  List<LatLng> polylineCoordinateList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

// Fixing Error null check
  String userName = 'your Name';
  String userEmail = 'your Email';

  bool openNavDrawer = true;
  bool activeNearbyTechnicianKeyLoaded = false;

  //Menampilkan ikon technician active-online
  BitmapDescriptor? activeNearbyIcon;

  //Mengakses list techician yang available
  List<ActiveNearbyAvailableTechnicians> onlineNearbyAvailableTechniciansList =
      [];

  //Menyimpan Request Service ke Database
  DatabaseReference? referenceServiceRequest;
  String technicianServiceStatus = "Technician is coming";
  StreamSubscription<DatabaseEvent>? serviceRequestInfoStreamSubscription;

  String userServiceRequestStatus = "";
  bool requestPositionInfo = true;

// Apabila izin diperbolehkan
  locationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

// Apabila izin ditolak
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateUserPosition() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = currentPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 15);
    newGoogleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
    // Memberi notifikasi bahwa human readable address berfungsi
    String humanReadableAddress =
        await AssistsMethods.searchAddressForGeoCoordinates(
            userCurrentPosition!, context);
    print("this is your address = $humanReadableAddress");

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    initializeGeofireListener();
    AssistsMethods.readServiceKeysForOnlineUser(context);
  }

  @override
  void initState() {
    super.initState();
    locationPermissionAllowed();
  }

  saveServiceRequestInfo() {
    //Menyimpan informasi permintaan service
    referenceServiceRequest =
        FirebaseDatabase.instance.ref().child("All Service Request").push();

    var originLocation =
        Provider.of<InfoApp>(context, listen: false).userPickUpLocation;
    var destinationLocation =
        Provider.of<InfoApp>(context, listen: false).userDropOffLocation;

    Map originLocationMap = {
      //"key": value
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      //"key": value
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };

    Map userInfoMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "technicianId": "waiting",
    };

    referenceServiceRequest!.set(userInfoMap);
    serviceRequestInfoStreamSubscription =
        referenceServiceRequest!.onValue.listen((eventSnap) async {
      if (eventSnap.snapshot.value == null) {
        return;
      }

      if ((eventSnap.snapshot.value as Map)["vehicle_details"] != null) {
        setState(() {
          technicianCarDetails =
              (eventSnap.snapshot.value as Map)["vehicle_details"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["technicianPhone"] != null) {
        setState(() {
          technicianPhone =
              (eventSnap.snapshot.value as Map)["technicianPhone"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["technicianName"] != null) {
        setState(() {
          technicianName =
              (eventSnap.snapshot.value as Map)["technicianName"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["status"] != null) {
        userServiceRequestStatus =
            (eventSnap.snapshot.value as Map)["status"].toString();
      }

      if ((eventSnap.snapshot.value as Map)["technicianLocation"] != null) {
        double technicianCurrentPositionLat = double.parse(
            (eventSnap.snapshot.value as Map)["technicianLocation"]["latitude"]
                .toString());
        double technicianCurrentPositionLng = double.parse(
            (eventSnap.snapshot.value as Map)["technicianLocation"]["longitude"]
                .toString());

        LatLng technicianCurrentPositionLatLng =
            LatLng(technicianCurrentPositionLat, technicianCurrentPositionLng);

        //status = accepted
        if (userServiceRequestStatus == "accepted") {
          updateArrivalTimeToUserPickupLocation(
              technicianCurrentPositionLatLng);
        }

        //status = arrived
        if (userServiceRequestStatus == "arrived") {
          setState(() {
            technicianServiceStatus = "technician has Arrived";
          });
        }

        ////status = onservice
        if (userServiceRequestStatus == "onservice") {
          updateReachingTimeToUserDropOffLocation(
              technicianCurrentPositionLatLng);
        }
      }
      //status = ended
      if (userServiceRequestStatus == "ended") {
        if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
          double fareAmount = double.parse(
              (eventSnap.snapshot.value as Map)["fareAmount"].toString());

          var response = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext c) => PayFareAmount(
              fareAmount: fareAmount,
            ),
          );

          if (response == "cashPayed") {
            //user can rate the technician now
            if ((eventSnap.snapshot.value as Map)["technicianId"] != null) {
              String assignedTechnicianId =
                  (eventSnap.snapshot.value as Map)["technicianId"].toString();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => RateTechnicianScreen(
                    assignedTechnicianId: assignedTechnicianId,
                  ),
                ),
              );

              referenceServiceRequest!.onDisconnect();
              serviceRequestInfoStreamSubscription!.cancel();
            }
          }
        }
      }
    });

    onlineNearbyAvailableTechniciansList =
        GeofireAssists.activeNearbyAvailableTechniciansList;
    searchNearestOnlineTechnicians();
  }

  updateArrivalTimeToUserPickupLocation(technicianCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      LatLng userPickUpPosition =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo =
          await AssistsMethods.obtainOriginToDestinationDirectionDetails(
        technicianCurrentPositionLatLng,
        userPickUpPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        technicianServiceStatus =
            "Technician is Coming : ${directionDetailsInfo.duration_text}";
      });

      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropOffLocation(
      technicianCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation =
          Provider.of<InfoApp>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
          dropOffLocation!.locationLatitude!,
          dropOffLocation.locationLongitude!);

      var directionDetailsInfo =
          await AssistsMethods.obtainOriginToDestinationDirectionDetails(
        technicianCurrentPositionLatLng,
        userDestinationPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        technicianServiceStatus =
            "Going towards destination :: ${directionDetailsInfo.duration_text}";
      });

      requestPositionInfo = true;
    }
  }

  searchNearestOnlineTechnicians() async {
    //No Active Technician available
    if (onlineNearbyAvailableTechniciansList.isEmpty) {
      //Harus membatalkan Service Request
      referenceServiceRequest!.remove();

      setState(() {
        polylineSet.clear();
        markerSet.clear();
        circleSet.clear();
        polylineCoordinateList.clear();
      });

      Fluttertoast.showToast(msg: "No online nearest Technician available");

      Fluttertoast.showToast(msg: "Try Again another time...");

      Future.delayed(const Duration(milliseconds: 4000), () {
        SystemNavigator.pop();
      });

      return;
    }

    // Active Technician available
    await retrieveOnlineTechnicianInfo(onlineNearbyAvailableTechniciansList);

    var response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectActiveTechnician(
                referenceServiceRequest: referenceServiceRequest)));

    if (response == "technicianChoosed") {
      FirebaseDatabase.instance
          .ref()
          .child("technicians")
          .child(technicianChosenId!)
          .once()
          .then((snap) {
        if (snap.snapshot.value != null) {
          // Send notification to spesific technician
          sendNotificationToTechnicianNow(technicianChosenId!);

          //Display Waiting response from a technician
          showWaitingResponseFromTechnicianUI();

          // Response from a Technician
          FirebaseDatabase.instance
              .ref()
              .child("technicians")
              .child(technicianChosenId!)
              .child("newServiceStatus")
              .onValue
              .listen((eventSnapshot) {
            // 1. Technician can Cancel the serviceRequest : Push Notification
            //(newServiceStatus = idle)
            if (eventSnapshot.snapshot.value == "idle") {
              Fluttertoast.showToast(
                  msg:
                      "The technician has cancelled your request. Please choose another technician.");

              Future.delayed(const Duration(milliseconds: 3000), () {
                Fluttertoast.showToast(msg: "Please Restart App Now.");

                SystemNavigator.pop();
              });
            }

            // 2. Technician can Accept the serviceRequest Push Notification
            //(newServiceStatus = accepted)
            if (eventSnapshot.snapshot.value == "accepted") {
              //design and display ui for displaying assigned technician information
              showUIForAssignedTechnicianInfo();
            }
          });
        } else {
          Fluttertoast.showToast(
              msg: "This technician doesn't exist. Try Again");
        }
      });
    }
  }

  sendNotificationToTechnicianNow(String technicanChosenId) {
    // Assign / SET serviceRequestId ke newServiceStatus in
    // Technicians Parent node untuk spesifik technician
    FirebaseDatabase.instance
        .ref()
        .child("technicians")
        .child(technicanChosenId)
        .child("newServiceStatus")
        .set(referenceServiceRequest!.key);

    //Otomatis mengirimkan push notification
    FirebaseDatabase.instance
        .ref()
        .child("technicians")
        .child(technicanChosenId)
        .child("token")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        String deviceRegistrationToken = snap.snapshot.value.toString();

        //send Notification Now
        AssistsMethods.sendNotificationToTechnicianNow(
          deviceRegistrationToken,
          referenceServiceRequest!.key.toString(),
          context,
        );

        Fluttertoast.showToast(msg: "Notification sent Successfully.");
      } else {
        Fluttertoast.showToast(msg: "Please choose another technician.");
        return;
      }
    });
  }

  showUIForAssignedTechnicianInfo() {
    setState(() {
      waitingResponseFromTechnicianContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedTechnicianInfoContainerHeight = 240;
    });
  }

  showWaitingResponseFromTechnicianUI() {
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromTechnicianContainerHeight = 220;
    });
  }

  retrieveOnlineTechnicianInfo(List onlineNearestTechniciansList) async {
    DatabaseReference reference =
        FirebaseDatabase.instance.ref().child("technicians");
    for (int i = 0; i < onlineNearestTechniciansList.length; i++) {
      await reference
          .child(onlineNearestTechniciansList[i].techniciansId.toString())
          .once()
          .then((dataSnapshot) {
        var technicianInfoKey = dataSnapshot.snapshot.value;
        techList.add(technicianInfoKey);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearbyTechnicianIconMarker();
    return Scaffold(
      key: scaffoldKey,
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color.fromARGB(255, 72, 147, 137),
        ),
        child: MyNavDrawer(
          name: userName,
          email: userEmail,
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            polylines: polylineSet,
            markers: markerSet,
            circles: circleSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerMap.complete(controller);
              newGoogleMapController = controller;

              // Menambahkan credit Google
              setState(() {
                bottomPaddingMap = 0;
              });

              locateUserPosition();
            },
          ),

          // Hamburger Button Drawer Custom
          Positioned(
            top: 36,
            left: 30,
            child: GestureDetector(
              onTap: () {
                if (openNavDrawer) {
                  scaffoldKey.currentState!.openDrawer();
                } else {
                  // Refresh dan Restart App Progmatically
                  SystemNavigator.pop();
                }
              },
              child: CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 72, 147, 137),
                child: Icon(
                  openNavDrawer ? Icons.menu_rounded : Icons.close_rounded,
                  color: Colors.white70,
                ),
              ),
            ),
          ),

          // Searching Location UI
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(235, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 15,
                  ),
                  child: Column(
                    children: [
                      //from
                      Row(
                        children: [
                          const Icon(
                            Icons.add_location_alt_outlined,
                            color: Color.fromARGB(255, 84, 82, 82),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "From",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 74, 72, 72),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                Provider.of<InfoApp>(context)
                                            .userPickUpLocation !=
                                        null
                                    ? "${(Provider.of<InfoApp>(context).userPickUpLocation!.locationName!).substring(0, 24)}..."
                                    : "not getting address",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 74, 72, 72),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 15,
                      ),
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Color.fromARGB(255, 158, 158, 158),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // to
                      GestureDetector(
                        onTap: () async {
                          // Mengarahkan ke Search Place Screen
                          var responseFromSearchScreen = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MySearchPlaceScreen()),
                          );

                          if (responseFromSearchScreen == "obtainedDropOff") {
                            setState(() {
                              openNavDrawer = false;
                            });

                            // Membuat rute - polyline
                            await drawPolyLineFromOriginToDestination();
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_location_alt_outlined,
                              color: Color.fromARGB(255, 74, 72, 72),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "To",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 74, 72, 72),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  Provider.of<InfoApp>(context)
                                              .userDropOffLocation !=
                                          null
                                      ? Provider.of<InfoApp>(context)
                                          .userDropOffLocation!
                                          .locationName!
                                      : "Choose Drop location",
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 74, 72, 72),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Color.fromARGB(255, 158, 158, 158),
                      ),
                      const SizedBox(
                        height: 15,
                      ),

                      ElevatedButton(
                        onPressed: () {
                          if (Provider.of<InfoApp>(context, listen: false)
                                  .userDropOffLocation !=
                              null) {
                            saveServiceRequestInfo();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please select destination");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 72, 147, 137),
                        ),
                        child: const Text(
                          'Request Service',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          //ui for waiting response from technician
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: waitingResponseFromTechnicianContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(
                        'Waiting for Response \nfrom technician',
                        duration: const Duration(seconds: 6),
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                            fontSize: 30.0,
                            color: const Color.fromARGB(255, 72, 147, 137),
                            fontWeight: FontWeight.bold),
                      ),
                      ScaleAnimatedText(
                        'Please wait...',
                        duration: const Duration(seconds: 10),
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                            fontSize: 32.0,
                            color: Colors.white12,
                            fontFamily: 'Canterbury'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //ui for displaying assigned technician information
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: assignedTechnicianInfoContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //status of ride
                    Center(
                      child: Text(
                        technicianServiceStatus,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 72, 147, 137),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey,
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    // technician vehicle details
                    Text(
                      technicianCarDetails,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 2.0,
                    ),

                    // technician name
                    Text(
                      technicianName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 63, 59, 59),
                      ),
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    //call technician button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 72, 147, 137),
                        ),
                        icon: const Icon(
                          Icons.phone_android_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        label: const Text(
                          "Call Technician",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> drawPolyLineFromOriginToDestination() async {
    var originPosition =
        Provider.of<InfoApp>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<InfoApp>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => MyProgressDialog(
        message: "Please wait...",
      ),
    );

    var directionDetailsInfo =
        await AssistsMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo!.e_point);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList =
        polylinePoints.decodePolyline(directionDetailsInfo.e_point!);

    polylineCoordinateList.clear();

    if (decodedPolylinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodedPolylinePointsResultList) {
        polylineCoordinateList.add(
          LatLng(pointLatLng.latitude, pointLatLng.longitude),
        );
      }
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          color: const Color.fromARGB(255, 72, 147, 137),
          polylineId: const PolylineId("PolylineID"),
          jointType: JointType.round,
          points: polylineCoordinateList,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      latLngBounds =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(latLngBounds, 65),
    );
    // Mengatur Marker
    Marker originMarker = Marker(
      markerId: const MarkerId('originID'),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('destinationID'),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });

    // Mengatur Circle
    Circle originCircle = Circle(
      circleId: const CircleId('originID'),
      fillColor: const Color.fromARGB(255, 224, 145, 60),
      radius: 12,
      strokeWidth: 5,
      strokeColor: Colors.white38,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId('destinationID'),
      fillColor: const Color.fromARGB(255, 219, 69, 69),
      radius: 12,
      strokeWidth: 5,
      strokeColor: Colors.white38,
      center: destinationLatLng,
    );

    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }

// Menerapkan Geofire untuk mencari technician terdekat
  initializeGeofireListener() {
    Geofire.initialize("activeTechnicians");
    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          //Kapanpun Technician active-online,
          case Geofire.onKeyEntered:
            // keysRetrieved.add(map["key"]);
            ActiveNearbyAvailableTechnicians activeNearbyAvailableTechnicians =
                ActiveNearbyAvailableTechnicians();
            activeNearbyAvailableTechnicians.locationLatitude = map['latitude'];
            activeNearbyAvailableTechnicians.locationLongitude =
                map['longitude'];
            activeNearbyAvailableTechnicians.techniciansId = map['key'];

            GeofireAssists.activeNearbyAvailableTechniciansList.add(
                activeNearbyAvailableTechnicians); //Hanya akan bekerja ketika technician online

            if (activeNearbyTechnicianKeyLoaded == true) {
              displayActiveTechnicianOnUserMap();
            }

            break;

          //Kapanpun Technician non-active atau offine
          case Geofire.onKeyExited:
            // keysRetrieved.remove(map["key"]);
            GeofireAssists.deleteOfflineTechnicianFromList(map['key']);
            displayActiveTechnicianOnUserMap();
            break;

          //Kapanpun Technician bergerak - update lokasi technician
          case Geofire.onKeyMoved:
            // Update your key's location
            ActiveNearbyAvailableTechnicians activeNearbyAvailableTechnicians =
                ActiveNearbyAvailableTechnicians();
            activeNearbyAvailableTechnicians.locationLatitude = map['latitude'];
            activeNearbyAvailableTechnicians.locationLongitude =
                map['longitude'];
            activeNearbyAvailableTechnicians.techniciansId = map['key'];

            GeofireAssists.updateActiveNearbyAvailableTechniciansLocation(
                activeNearbyAvailableTechnicians);
            displayActiveTechnicianOnUserMap();
            break;

          //Display semua technician yang online
          case Geofire.onGeoQueryReady:
            activeNearbyTechnicianKeyLoaded = true;
            displayActiveTechnicianOnUserMap();
            break;
        }
      }

      setState(() {});
    });
  }

  displayActiveTechnicianOnUserMap() {
    setState(() {
      markerSet.clear();
      circleSet.clear();

      Set<Marker> technicianMarkerSet = <Marker>{};
      for (ActiveNearbyAvailableTechnicians eachTechnician
          in GeofireAssists.activeNearbyAvailableTechniciansList) {
        LatLng eachTechnicianActivePosition = LatLng(
            eachTechnician.locationLatitude!,
            eachTechnician.locationLongitude!);
        Marker marker = Marker(
          markerId: MarkerId(eachTechnician.techniciansId!),
          position: eachTechnicianActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        technicianMarkerSet.add(marker);
      }

      setState(() {
        markerSet = technicianMarkerSet;
      });
    });
  }

  createActiveNearbyTechnicianIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/technician.png")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }
}
