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
              SizedBox(height: 25.0),
              Text(
                driversInformation.name,
                style: TextStyle(fontSize: 35.0, color: Colors.blueAccent, fontWeight: FontWeight.bold, 
                fontFamily: "Vanberg"),
              ),

              SizedBox(
                height: 20.0,
                width: 200.0,
                child: Divider(
                  height: 2.0, 
                  thickness: 2.0,
                  color: Colors.grey,
                  ),
              ),
              SizedBox(height: 10.0),

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
              SizedBox(height: 30.0),
              
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
                text:driversInformation.car_color + "  " + driversInformation.car_model + "  " + driversInformation.car_number,
                icon: Icons.car_repair,
                onPressed: () async
                {
                  print("This is car details");
                },
              ),

              SizedBox(height: 30.0),

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
                Icons.logout,
               color:  Colors.white,

                ),
              title: Text(
                  "Sign out",
              textAlign:  TextAlign.center,    
              style:
              TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600,
              fontSize: 20.0,
              fontFamily: "Brand bold",

              ),
             ),
             ),
             ),
             ),
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