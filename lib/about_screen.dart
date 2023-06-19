import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          //image
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
            child: Image.asset("assets/images/dispatch.png"),
          ),

          Column(
            children: [
              //about you & your company - write some info
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  "This app has been developed by Syifa Prameswari, "
                  "This is the world number 1 Dispatch App. Available for all. ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              const SizedBox(
                height: 40,
              ),

              //close
              ElevatedButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 56, 120, 240),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    )),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: "PTSans",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
