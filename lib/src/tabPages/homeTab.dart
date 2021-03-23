import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jitney_cabs_driver/src/assistants/assistantMethods.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';

class HomeTab extends StatelessWidget {

Completer<GoogleMapController> _controllerGoogleMap = Completer();
GoogleMapController newGoogleMapController;

 static final CameraPosition _kGooglePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
  );

  Position currentPosition;
  var geolocator = Geolocator();

  void locatePosition() async
  {
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  currentPosition = position;

  LatLng latLngPosition = LatLng(position.latitude, position.longitude);
  CameraPosition cameraPosition = new CameraPosition(target: latLngPosition, zoom: 14);
  newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

  // String address = await AssistantMethods.searchCoordinateAddress(position, context);
  //print("This is your address:: "+ address);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:[
         GoogleMap(
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            //zoomControlsEnabled: true,
            //zoomGesturesEnabled: true,
            
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              
              locatePosition();
            }
           ),

           //Online and offline driver container...
           Container
           (
             height:140.0,
             width: double.infinity,
             color: Colors.black54,
           ),

           Positioned(
             top: 60.0,
             left:0.0,
             right: 0.0,

             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children:[
                    Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
                     // ignore: deprecated_member_use
                     child: RaisedButton(
                       onPressed: ()
                       {
                               
                        }, 
                     color: Colors.greenAccent[700],   
                     child: Padding(
                       padding: const EdgeInsets.all(17.0),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                             Text("Online now", style: TextStyle(color: white,fontSize: 20.0,fontWeight: FontWeight.bold),),
                              Icon(Icons.phone_android, color: white, size: 26.0,),
                            ],
                        ),
                      ),
                     ),
                    ),
                  ]
             ),
           ),
      ]
    );
      
    
  }
}