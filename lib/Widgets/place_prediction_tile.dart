import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/Assists/request_assists.dart';
import 'package:user_app/Global/global.dart';
import 'package:user_app/Global/google_maps_key.dart';
import 'package:user_app/InfoHandler/direction_handler.dart';
import 'package:user_app/InfoHandler/info_handler_app.dart';
import 'package:user_app/Models/predicted_places.dart';
import 'package:user_app/Widgets/progress_dialog.dart';

class MyPlacePredictionTileDesign extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;
  const MyPlacePredictionTileDesign({super.key, this.predictedPlaces});

  @override
  State<MyPlacePredictionTileDesign> createState() =>
      _MyPlacePredictionTileDesignState();
}

class _MyPlacePredictionTileDesignState
    extends State<MyPlacePredictionTileDesign> {
  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => MyProgressDialog(
              message: 'Setting Up Drop-Off, Please wait...',
            ));

    String placeDirectionDetailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';

    var responseAPI =
        await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context);

    if (responseAPI == "Error Occurred, Failed. No Response.") {
      return;
    }
    if (responseAPI["status"] == "OK") {
      Directions directions = Directions();

      directions.locationName = responseAPI["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude =
          responseAPI["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =
          responseAPI["result"]["geometry"]["location"]["lng"];

      Provider.of<InfoApp>(context, listen: false)
          .updateDropOffLocationAddress(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });

      Navigator.pop(context, "obtainedDropoff");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        getPlaceDirectionDetails(widget.predictedPlaces!.place_id, context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          children: [
            const Icon(
              Icons.add_location_rounded,
              color: Color.fromARGB(255, 146, 201, 193),
            ),
            const SizedBox(
              width: 14,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                // Main Text
                Text(
                  widget.predictedPlaces!.main_text!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 84, 82, 82),
                  ),
                ),
                // Secondary Text
                const SizedBox(
                  height: 2,
                ),
                Text(
                  widget.predictedPlaces!.secondary_text!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 107, 104, 104),
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
