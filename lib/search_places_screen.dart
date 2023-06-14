import 'package:flutter/material.dart';
import 'package:user_app/Assists/request_assists.dart';
import 'package:user_app/Global/google_maps_key.dart';
import 'package:user_app/Models/predicted_places.dart';
import 'package:user_app/Widgets/place_prediction_tile.dart';

class MySearchPlaceScreen extends StatefulWidget {
  const MySearchPlaceScreen({super.key});

  @override
  State<MySearchPlaceScreen> createState() {
    return _MySearchPlaceScreenState();
  }
}

class _MySearchPlaceScreenState extends State<MySearchPlaceScreen> {
  List<PredictedPlaces> placePredictedList = [];

  void findPlaceAutoComplete(String inputText) async {
    if (inputText.length > 1) //More than 2 input characters
    {
      String urlAutoComplete =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:ID';

      var responseAutoComplete =
          await RequestAssistant.receiveRequest(urlAutoComplete);

      if (responseAutoComplete == 'Error Occurred, Failed. No Response.') {
        return;
      }
      if (responseAutoComplete["status"] == "OK") {
        var placePrediction = responseAutoComplete["predictions"];

        var placePredictionList = (placePrediction as List)
            .map((jsonData) => PredictedPlaces.fromJson(jsonData))
            .toList();
        setState(() {
          placePredictedList = placePredictionList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [
        // Search Place UI
        Container(
          height: 180,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 72, 147, 137),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 132, 134, 134),
                blurRadius: 0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              const SizedBox(height: 20),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Search and Set DropOff Location',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.adjust_rounded,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        onChanged: (valueTyped) {
                          findPlaceAutoComplete(valueTyped);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Want to go somewhere?',
                          fillColor: Color.fromARGB(255, 146, 201, 193),
                          filled: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                            left: 12,
                            top: 8,
                            bottom: 8,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ]),
          ),
        ),

        // Display Place Prediction result
        (placePredictedList.isNotEmpty)
            ? Expanded(
                child: ListView.separated(
                  itemCount: placePredictedList.length,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return MyPlacePredictionTileDesign(
                      predictedPlaces: placePredictedList[index],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: Color.fromARGB(255, 158, 158, 158),
                    );
                  },
                ),
              )
            : Container(),
      ]),
    );
  }
}
