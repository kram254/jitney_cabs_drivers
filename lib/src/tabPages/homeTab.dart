import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jitney_cabs_driver/main.dart';
import 'package:jitney_cabs_driver/src/assistants/assistantMethods.dart';
import 'package:jitney_cabs_driver/src/helpers/configMaps.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:jitney_cabs_driver/src/helpers/toastDisplay.dart';
//import 'package:jitney_cabs_driver/src/notifications/pushNotificationServices.dart';
import 'package:jitney_cabs_driver/src/models/drivers.dart';

class HomeTab extends StatefulWidget {

 static final CameraPosition _kGooglePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
  );

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
Completer<GoogleMapController> _controllerGoogleMap = Completer();

GoogleMapController newGoogleMapController;

  var geolocator = Geolocator();


  String driverStatusText = "Offline now - Go online";

  Color driverStatusColor = black;

  bool isDriverAvailable = false;

  @override
    void initState() {
      
      super.initState();

      getCurrentDriverInfo();
    }

  getRideType()
  {
    driversRef.child(currentfirebaseUser.uid).child("car_details").child("type").once().then((DataSnapshot snapshot)
    {
      if(snapshot.value != null)
      {
        setState(() {
          rideType = snapshot.value.toString();
        });
      }
    });
  }
  getRatings()
    {
  // ratings
  driversRef.child(currentfirebaseUser.uid).child("ratings").once().then((DataSnapshot dataSnapshot)
  {
    if(dataSnapshot.value != null )
    {
      double ratings = double.parse(dataSnapshot.value.toString());
       setState(() {
         starCounter = ratings;
       });

                  if(starCounter <= 1.5)
                  {
                    setState(() {
                      title = "Very bad"; 
                    });                    
                    return;                   
                  }
                  if(starCounter <= 2.5)
                  {
                    setState(() {
                      title = "Bad"; 
                    }); 
                     return;
                  }
                  if(starCounter <= 3.5)
                  {
                    setState(() {
                      title = "Good"; 
                    });
                    return;
                  }
                  if(starCounter <= 4.5)
                  {
                    setState(() {
                      title = "Very good"; 
                    });
                    return;
                  }
                  if(starCounter <= 5.5)
                  {
                    setState(() {
                      title = "Excellent"; 
                    });
                      return;
                  }
    }
  });
 }

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

  void getCurrentDriverInfo() async
  {
     currentfirebaseUser = await FirebaseAuth.instance.currentUser;
     driversRef.child(currentfirebaseUser.uid).once().then((DataSnapshot dataSnapshot)
     {
       if(dataSnapshot.value != null)
       {
        driversInformation = Drivers.fromSnapshot(dataSnapshot);   
       }

     });

  //    MyApp myApp = MyApp();
 
  //    myApp.initializeApp(context);
  //    myApp.getToken();

       AssistantMethods.retrieveHistoryInfo(context);
       getRatings();
       getRideType();
   }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:[
         GoogleMap(
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: HomeTab._kGooglePlex,
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
                          if(isDriverAvailable != true)
                          {
                            makeDriverOnlineNow();
                            getLocationLiveUpdates();

                            setState(() {
                              driverStatusColor = Colors.greenAccent[700];
                              driverStatusText = "Online now";
                              isDriverAvailable = true;
                                                          
                            });
                            displayToastMessage("You're now Online", context);
                          }
                          else
                          {
                            makeDriverOfflineNow();
                            setState(() {
                              driverStatusColor = black;
                              driverStatusText = "Offline now - Go Online";
                              isDriverAvailable = false;                                                          
                            });
                            displayToastMessage("You're now Offline", context);
                          }
                        }, 
                     color: driverStatusColor,   
                     child: Padding(
                       padding: const EdgeInsets.all(17.0),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                             Text(driverStatusText ,style: TextStyle(color: white,fontSize: 20.0,fontWeight: FontWeight.bold),),
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

  void makeDriverOnlineNow () async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    Geofire.initialize("availableDrivers");
    Geofire.setLocation(currentfirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);
    
    rideRequestRef.set("searching");
    rideRequestRef.onValue.listen((event) 
    { 

    });
  }

  void getLocationLiveUpdates()
  {
    homeTabStreamSubscription = Geolocator.getPositionStream().listen((Position position)
    {
      currentPosition = position;
      if(isDriverAvailable = true)
      {
        Geofire.setLocation(currentfirebaseUser.uid, position.latitude, position.longitude);
      }
      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
     });
  }

  void makeDriverOfflineNow()
  {
    Geofire.removeLocation(currentfirebaseUser.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
    rideRequestRef = null;
  }
}