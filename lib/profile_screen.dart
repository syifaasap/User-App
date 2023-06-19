import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 120,
              height: 120,
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile.png'),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            //name
            Center(
              child: Text(
                userModelCurrentInfo!.name!,
                style: const TextStyle(
                    fontSize: 30.0,
                    color: Color.fromARGB(255, 35, 53, 88),
                    fontWeight: FontWeight.bold,
                    fontFamily: "PTSans"),
              ),
            ),

            const SizedBox(
              height: 40,
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
            )
          ],
        ),
      ),
    );
  }
}
