import 'package:flutter/material.dart';
import 'package:user_app/Global/global.dart';
import 'package:user_app/about_screen.dart';
import 'package:user_app/profile_screen.dart';
import 'package:user_app/service_history_screen.dart';
import 'package:user_app/splash_screen.dart';

// ignore: must_be_immutable
class MyNavDrawer extends StatefulWidget {
  String? email;
  String? name;

  MyNavDrawer({
    super.key,
    this.email,
    this.name,
  });

  @override
  State<MyNavDrawer> createState() {
    return _MyNavDrawerState();
  }
}

class _MyNavDrawerState extends State<MyNavDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              DrawerHeader(
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.name.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.email.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(203, 226, 217, 217),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),

          const Divider(
            height: 1,
            thickness: 0.5,
            color: Color.fromARGB(162, 223, 216, 216),
          ),
          const SizedBox(
            height: 12,
          ),
          // Body
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ServiceHistoryScreen(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(
                Icons.history_rounded,
                color: Colors.white,
              ),
              title: Text(
                'History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ProfileScreen(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(
                Icons.person_rounded,
                color: Colors.white,
              ),
              title: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => AboutScreen(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(
                Icons.info_rounded,
                color: Colors.white,
              ),
              title: Text(
                'About',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              firebaseAuth.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const MySplashScreen()));
            },
            child: const ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: Colors.white,
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
