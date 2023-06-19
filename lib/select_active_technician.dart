import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:user_app/Assists/assists_method.dart';
import 'package:user_app/Global/global.dart';

class SelectActiveTechnician extends StatefulWidget {
  DatabaseReference? referenceServiceRequest;

  SelectActiveTechnician({super.key, this.referenceServiceRequest});

  @override
  State<SelectActiveTechnician> createState() {
    return _SelectActiveTechnicianState();
  }
}

class _SelectActiveTechnicianState extends State<SelectActiveTechnician> {
  String fareAmount = '';
  getFareAMountAccordingVehicleType(int index) {
    if (tripDirectionDetailsInfo != null) {
      if (techList[index]['vehicle_details']['type'].toString() ==
          'motorcycle') {
        fareAmount = (AssistsMethods.calculateFairAmountFromOrigintoDestination(
                    tripDirectionDetailsInfo!) /
                2)
            .toStringAsFixed(1);
      }
      if (techList[index]['vehicle_details']['type'].toString() == 'car') {
        fareAmount = (AssistsMethods.calculateFairAmountFromOrigintoDestination(
                tripDirectionDetailsInfo!))
            .toStringAsFixed(1);
      }
      if (techList[index]['vehicle_details']['type'].toString() == 'van') {
        fareAmount = (AssistsMethods.calculateFairAmountFromOrigintoDestination(
                    tripDirectionDetailsInfo!) *
                2)
            .toStringAsFixed(1);
      }
    }
    return fareAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 35, 53, 88),
        title: const Text(
          "Service History",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, fontFamily: "PTSans"),
        ),
        leading: IconButton(
            onPressed: () {
              //Delete service request from database
              widget.referenceServiceRequest!.remove();

              Fluttertoast.showToast(
                  msg: 'You have canceled the service request');

              SystemNavigator.pop();
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
            )),
      ),
      body: ListView.builder(
        itemCount: techList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                technicianChosenId = techList[index]["id"].toString();
              });
              Navigator.pop(context, "technicianChoosed");
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
              child: Card(
                color: Colors.white,
                elevation: 3,
                shadowColor: Colors.grey[700],
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.asset(
                      "assets/images/${techList[index]['vehicle_details']['type']}.png",
                      width: 60,
                    ),
                  ),
                  title: Column(
                    children: [
                      Text(
                        techList[index]["name"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 74, 72, 72),
                        ),
                      ),
                      Text(
                        techList[index]["vehicle_details"]["vehicle_model"],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      SmoothStarRating(
                        rating: techList[index]["ratings"] == null
                            ? 0.0
                            : double.parse(techList[index]["ratings"]),
                        color: const Color.fromARGB(255, 38, 65, 62),
                        borderColor: const Color.fromARGB(255, 38, 65, 62),
                        allowHalfRating: true,
                        starCount: 5,
                        size: 16,
                      )
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Rp" + getFareAMountAccordingVehicleType(index),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tripDirectionDetailsInfo != null
                            ? tripDirectionDetailsInfo!.duration_text!
                            : '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tripDirectionDetailsInfo != null
                            ? tripDirectionDetailsInfo!.distance_text!
                            : '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
