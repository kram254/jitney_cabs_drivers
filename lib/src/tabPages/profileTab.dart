import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:jitney_cabs_driver/main.dart';
import 'package:jitney_cabs_driver/src/helpers/configMaps.dart';
import 'package:jitney_cabs_driver/src/screens/loginScreen.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: Column(
            children:[
              Text(
                driversInformation.name,
                style: TextStyle(fontSize: 65.0, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Signatra"),
              ),

              Text(
                title + " driver",
                style: TextStyle(fontSize: 20.0, color: Colors.blueGrey, letterSpacing: 2.5, fontWeight: FontWeight.bold, fontFamily: "Brand regular"),
              ),

              SizedBox(
                height: 20.0,
                width: 200.0,
                child: Divider(
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40.0),
              
              InfoCard(
                text:driversInformation.phone,
                icon: Icons.phone,
                onPressed: () async
                {
                  print("This is phone");
                },

              ),

               InfoCard(
                text:driversInformation.email,
                icon: Icons.email,
                onPressed: () async
                {
                  print("This is email");
                },

              ),

               InfoCard(
                text:driversInformation.car_color + " " + driversInformation.car_model + " " + driversInformation.car_number,
                icon: Icons.car_repair,
                onPressed: () async
                {
                  print("This is car details");
                },

              ),

              GestureDetector(
              onTap: ()
              {
                 Geofire.removeLocation(currentfirebaseUser.uid);
                 rideRequestRef.onDisconnect();
                 rideRequestRef.remove();
                 rideRequestRef = null;

                 FirebaseAuth.instance.signOut();
                 Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
              },
              child:  Card(
              color: Colors.red,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 115.0),
              child: ListTile(
              trailing: Icon(
                Icons.follow_the_signs_outlined,
               color:  Colors.white,

                ),
              title: Text(
                  "Signed out",
              textAlign:  TextAlign.center,    
              style:
              TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: "Brand bold",

            ),
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

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  Function onPressed;

  InfoCard({this.text,this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child:  Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
        child: ListTile(
          leading: Icon(
            icon,
            color:  Colors.black87,

          ),
          title: Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
              fontFamily: "Brand bold",

            ),
          ),
        ),
      ),
    );
  }
}