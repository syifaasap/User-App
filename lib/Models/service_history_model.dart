import 'package:firebase_database/firebase_database.dart';

class ServiceHistoryModel {
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? vehicle_details;
  String? technicianName;

  ServiceHistoryModel(
      {this.destinationAddress,
      this.fareAmount,
      this.originAddress,
      this.status,
      this.technicianName,
      this.time,
      this.vehicle_details});

  ServiceHistoryModel.fromSnapshot(DataSnapshot dataSnapshot) {
    time = (dataSnapshot.value as Map)["time"];
    originAddress = (dataSnapshot.value as Map)["originAddress"];
    destinationAddress = (dataSnapshot.value as Map)["destinationAddress"];
    status = (dataSnapshot.value as Map)["status"];
    fareAmount = (dataSnapshot.value as Map)["fareAmount"];
    vehicle_details = (dataSnapshot.value as Map)["vehicle_details"];
    technicianName = (dataSnapshot.value as Map)["technicianName"];
  }
}
