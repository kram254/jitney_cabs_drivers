import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';
import 'package:jitney_cabs_driver/src/models/rideDetails.dart';

class NewRideScreen extends StatefulWidget {
  final RideDetails rideDetails;
  NewRideScreen({this.rideDetails});

  static final CameraPosition _kGooglePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
  );

  @override
  _NewRideScreenState createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> 
{
 Completer<GoogleMapController> _controllerGoogleMap = Completer();
 GoogleMapController newRideGoogleMapController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: NewRideScreen._kGooglePlex,
            myLocationEnabled: true,
            //zoomControlsEnabled: true,
            //zoomGesturesEnabled: true,
            
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newRideGoogleMapController = controller;
             
            }
           ),

           Positioned(
             left: 0.0,
             right: 0.0,
             bottom: 0.0,
             child: Container(
               decoration: BoxDecoration(
                 color: white,
                 borderRadius: BorderRadius.only(topLeft:Radius.circular(16.0), topRight:Radius.circular(16.0)),
                 boxShadow: [
                   BoxShadow(
                     color: black,
                     blurRadius: 16.0,
                     spreadRadius: 0.6,
                     offset: Offset(0.7, 0.7),
                   ),
                 ]
               ),
               height: 260.0,
               child: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                 child: Column(
                   children: [
                     Text("10 minutes",
                     style: TextStyle(fontSize: 14, color: Colors.deepPurple)
                     ),
                     SizedBox(height: 6.0,),

                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text("Karios", style: TextStyle(fontSize: 24.0),),
                         Padding(
                           padding: EdgeInsets.only(right: 10.0),
                           child: Icon(Icons.phone_android_outlined),
                         ),
                       ],
                     ),
                     SizedBox(height: 26.0,),

                     Row(
                       children: [
                         Image.asset("images/pickicon.png",height: 16.0, width:16.0),
                         SizedBox(width: 18.0,),
                         Expanded(
                           child: Text(
                             "Ruiru, Nairobi",
                             style: TextStyle(fontSize: 18.0),
                             overflow: TextOverflow.ellipsis,
                           ),
                           )
                       ],
                       ),

                       SizedBox(height: 16.0,),

                     Row(
                       children: [
                         Image.asset("images/desticon.png",height: 16.0, width:16.0),
                         SizedBox(width: 18.0,),
                         Expanded(
                           child: Text(
                             "Ngong Road, Nairobi",
                             style: TextStyle(fontSize: 18.0),
                             overflow: TextOverflow.ellipsis,
                           ),
                           )
                       ],
                       ), 

                       SizedBox(height: 26.0,),

                       Padding(
                         padding: EdgeInsets.symmetric(horizontal: 16.0),
                         // ignore: deprecated_member_use
                         child: RaisedButton(
                           onPressed: () {},
                           color: Theme.of(context).accentColor,
                           child: Padding(
                             padding: EdgeInsets.all(17.0),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Text("Arrived", 
                                 style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold,color: white),
                                 ),
                                 Icon(Icons.directions_car, color: white, size: 26.0,),
                                 
                               ],
                             ),
                             ),
                           ),
                       ) 
                   ],
                 ),
               ),
             ),
           ),

        ],
      ),
      
    );
  }
}