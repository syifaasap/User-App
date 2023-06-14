import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_app/Assists/request_assists.dart';
import 'package:user_app/InfoHandler/info_handler_app.dart';
import 'package:user_app/Models/directions_details.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Models/service_history_model.dart';
import '../Global/global.dart';
import '../Global/google_maps_key.dart';
import '../InfoHandler/direction_handler.dart';
import '../Models/user_models.dart';

class AssistsMethods {
  static Future<String> searchAddressForGeoCoordinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occurred, Failed. No Response.") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<InfoApp>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static void readCurrentOnlineUserInfo() async {
    currentFirebaseUser = firebaseAuth.currentUser;

    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<DirectionDetailInfo?> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionAPI = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    if (responseDirectionAPI == "Error Occurred, Failed. No Response.") {
      return null;
    }

    DirectionDetailInfo directionDetailsInfo = DirectionDetailInfo();
    directionDetailsInfo.e_point =
        responseDirectionAPI["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text =
        responseDirectionAPI["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionAPI["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text =
        responseDirectionAPI["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionAPI["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static double calculateFairAmountFromOrigintoDestination(
      DirectionDetailInfo directionDetailsInfo) {
    double timeTraveledFareAmountPerMinute =
        (directionDetailsInfo.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer =
        (directionDetailsInfo.duration_value! / 1000) * 0.1;

    //1 USD = 15000 Rupiah
    double totalFareAmount = timeTraveledFareAmountPerMinute +
        distanceTraveledFareAmountPerKilometer;
    double localCurrencytotalFareAmount = totalFareAmount * 15000;

    return double.parse(localCurrencytotalFareAmount.toStringAsFixed(1));
  }

  static sendNotificationToTechnicianNow(String deviceRegistrationToken,
      String userServiceRequestId, context) async {
    String destinationAddress = userDropOffAddress;

    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    Map bodyNotification = {
      "body": "Destination Address: \n$destinationAddress.",
      "title": "Syifa Dispatch App"
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "serviceRequestId": userServiceRequestId,
    };

    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken,
    };

    var responseNotification = http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );
  }

  //retrieve the service KEYS for online user
  //service key = service request key
  static void readServiceKeysForOnlineUser(context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Service Request")
        .orderByChild("userName")
        .equalTo(userModelCurrentInfo!.name)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        Map keysServiceId = snap.snapshot.value as Map;

        //count total number services and share it with Provider
        int overAllServiceCounter = keysServiceId.length;
        Provider.of<InfoApp>(context, listen: false)
            .updateOverAllServiceCounter(overAllServiceCounter);

        //share services keys with Provider
        List<String> serviceKeysList = [];
        keysServiceId.forEach((key, value) {
          serviceKeysList.add(key);
        });
        Provider.of<InfoApp>(context, listen: false)
            .updateOverAllServiceKeys(serviceKeysList);

        //get services keys data - read services complete information
        readServiceHistoryInformation(context);
      }
    });
  }

  static void readServiceHistoryInformation(context) {
    var servicesAllKeys =
        Provider.of<InfoApp>(context, listen: false).historyServiceKeysList;

    for (String eachKey in servicesAllKeys) {
      FirebaseDatabase.instance
          .ref()
          .child("All Service Request")
          .child(eachKey)
          .once()
          .then((snap) {
        var eachServiceHistory =
            ServiceHistoryModel.fromSnapshot(snap.snapshot);

        if ((snap.snapshot.value as Map)["status"] == "ended") {
          //update-add each history to OverAllService History Data List
          Provider.of<InfoApp>(context, listen: false)
              .updateOverAllServiceHistoryInformation(eachServiceHistory);
        }
      });
    }
  }
}
