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
            color: Color.fromARGB(255, 35, 53, 88),
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
              const SizedBox(height: 25),
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
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "PTSans"),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        color: Colors.grey[100],
                        child: TextField(
                          onChanged: (valueTyped) {
                            findPlaceAutoComplete(valueTyped);
                          },
                          decoration: InputDecoration(
                            hintText: 'Want to go somewhere?',
                            prefixIcon: Icon(
                              Icons.adjust_rounded,
                              color: Colors.grey[600],
                            ),
                            fillColor: Colors.grey[200],
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.only(
                              left: 12,
                              top: 8,
                              bottom: 6,
                            ),
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
                    return Divider(
                        height: 0.5, thickness: 0.5, color: Colors.grey[300]);
                  },
                ),
              )
            : Container(),
      ]),
    );
  }
}
