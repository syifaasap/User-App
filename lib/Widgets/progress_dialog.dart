import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyProgressDialog extends StatelessWidget {
  String? message;
  MyProgressDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 68, 81, 78),
      child: Container(
        margin: const EdgeInsets.all(5),
        // decoration: BoxDecoration(
        //   color: const Color.fromARGB(255, 24, 75, 69),
        //   borderRadius: BorderRadius.circular(10),
        // ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 186, 180, 180),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                message!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
