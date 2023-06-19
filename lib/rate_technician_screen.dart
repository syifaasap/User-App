import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:user_app/Global/global.dart';

class RateTechnicianScreen extends StatefulWidget {
  String? assignedTechnicianId;
  RateTechnicianScreen({super.key, this.assignedTechnicianId});

  @override
  State<RateTechnicianScreen> createState() {
    return _RateTechnicianScreenState();
  }
}

class _RateTechnicianScreenState extends State<RateTechnicianScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500],
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white60,
        child: Container(
          margin: const EdgeInsets.all(2),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 22.0,
              ),
              Text(
                "How was the technician?",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  fontFamily: "PTSans",
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(
                height: 22.0,
              ),
              const Divider(
                height: 1.0,
                thickness: 1.0,
              ),
              const SizedBox(
                height: 22.0,
              ),
              SmoothStarRating(
                rating: countRatingStars,
                allowHalfRating: false,
                starCount: 5,
                color: const Color.fromARGB(255, 35, 53, 88),
                borderColor: const Color.fromARGB(255, 35, 53, 88),
                size: 46,
                onRatingChanged: (valueOfStarsChoosed) {
                  countRatingStars = valueOfStarsChoosed;

                  if (countRatingStars == 1) {
                    setState(() {
                      titleStarsRating = "Very Bad";
                    });
                  }
                  if (countRatingStars == 2) {
                    setState(() {
                      titleStarsRating = "Bad";
                    });
                  }
                  if (countRatingStars == 3) {
                    setState(() {
                      titleStarsRating = "Good";
                    });
                  }
                  if (countRatingStars == 4) {
                    setState(() {
                      titleStarsRating = "Very Good";
                    });
                  }
                  if (countRatingStars == 5) {
                    setState(() {
                      titleStarsRating = "Excellent";
                    });
                  }
                },
              ),
              const SizedBox(
                height: 12.0,
              ),
              Text(
                titleStarsRating,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 70, 81, 79),
                ),
              ),
              const SizedBox(
                height: 18.0,
              ),
              ElevatedButton(
                  onPressed: () {
                    DatabaseReference rateTechnicianRef = FirebaseDatabase
                        .instance
                        .ref()
                        .child("technicians")
                        .child(widget.assignedTechnicianId!)
                        .child("ratings");

                    rateTechnicianRef.once().then((snap) {
                      if (snap.snapshot.value == null) {
                        rateTechnicianRef.set(countRatingStars.toString());

                        SystemNavigator.pop();
                      } else {
                        double pastRatings =
                            double.parse(snap.snapshot.value.toString());
                        double newAverageRatings =
                            (pastRatings + countRatingStars) / 2;
                        rateTechnicianRef.set(newAverageRatings.toString());

                        SystemNavigator.pop();
                      }

                      Fluttertoast.showToast(msg: "Please Restart App Now");
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 56, 120, 240),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: "PTSans"),
                  )),
              const SizedBox(
                height: 18.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
