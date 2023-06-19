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
      backgroundColor: Colors.grey[200],
      child: ListView(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/profile.png'),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            widget.name.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                              fontFamily: "PTSans",
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.email.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: Colors.grey.shade500,
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
                  builder: (BuildContext context) =>
                      const ServiceHistoryScreen(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(
                Icons.history_rounded,
                size: 30,
                color: Color.fromARGB(255, 35, 53, 88),
              ),
              title: Text(
                'History',
                style: TextStyle(
                    color: Color.fromARGB(255, 35, 53, 88),
                    fontSize: 16,
                    fontFamily: "PTSans"),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const ProfileScreen(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(
                Icons.person_rounded,
                size: 30,
                color: Color.fromARGB(255, 35, 53, 88),
              ),
              title: Text(
                'Profile',
                style: TextStyle(
                    color: Color.fromARGB(255, 35, 53, 88),
                    fontSize: 16,
                    fontFamily: "PTSans"),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const AboutScreen(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(
                Icons.info_rounded,
                size: 30,
                color: Color.fromARGB(255, 35, 53, 88),
              ),
              title: Text(
                'About',
                style: TextStyle(
                    color: Color.fromARGB(255, 35, 53, 88),
                    fontSize: 16,
                    fontFamily: "PTSans"),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              firebaseAuth.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => const MySplashScreen(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(
                Icons.logout_rounded,
                size: 30,
                color: Color.fromARGB(255, 35, 53, 88),
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(
                    color: Color.fromARGB(255, 35, 53, 88),
                    fontSize: 16,
                    fontFamily: "PTSans"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
