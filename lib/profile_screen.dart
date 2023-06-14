import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:user_app/Global/global.dart';
import 'package:user_app/Widgets/info_design.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 72, 147, 137),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //name
            Center(
              child: Text(
                userModelCurrentInfo!.name!,
                style: const TextStyle(
                  fontSize: 30.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              height: 10,
              width: 200,
            ),

            const SizedBox(
              height: 25.0,
            ),

            //phone
            InfoDesignUI(
              textInfo: userModelCurrentInfo!.phone!,
              iconData: Icons.phone_iphone_rounded,
            ),

            //email
            InfoDesignUI(
              textInfo: userModelCurrentInfo!.email!,
              iconData: Icons.email_rounded,
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text(
                "Close",
                style: TextStyle(
                  color: Color.fromARGB(255, 72, 147, 137),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
