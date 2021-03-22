import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jitney_cabs_driver/src/assistants/assistantMethods.dart';
import 'package:jitney_cabs_driver/src/helpers/configMaps.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';
import 'package:jitney_cabs_driver/src/models/directionDetails.dart';
import 'package:jitney_cabs_driver/src/providers/appData.dart';
import 'package:jitney_cabs_driver/src/screens/loginScreen.dart';
import 'package:jitney_cabs_driver/src/screens/searchScreen.dart';
import 'package:jitney_cabs_driver/src/widgets/Divider.dart';
import 'package:jitney_cabs_driver/src/widgets/progressDialog.dart';
import 'package:jitney_cabs_driver/src/screens/loginScreen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String idScreen = "homeScreen";
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin
{

Completer<GoogleMapController> _controllerGoogleMap = Completer();
GoogleMapController newGoogleMapController;
GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

DirectionDetails tripDirectionDetails;

List<LatLng> pLineCoordinates = [];
Set<Polyline> polylineSet = {};
Set<Marker> markerSet = {};
Set<Circle> circleSet = {};
Position currentPosition;
var geolocator = Geolocator();
double bottomPaddingOfMap = 0;
double rideDetailsContainerHeight = 0;
double requestRideContainerHeight = 0;
double searchContainerHeight = 300.0;
DatabaseReference rideRequestRef;
bool drawerOpen = true;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

 void saveRideRequest()
 {
   rideRequestRef = FirebaseDatabase.instance.reference().child("Ride Requests").push();

   var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;

   var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

   Map pickUpLocMap =
   {
     "latitude": pickUp.latitude.toString(),
     "longitude": pickUp.longitude.toString(),
   };

   Map dropOffLocMap =
   {
     "latitude": dropOff.latitude.toString(),
     "longitude": dropOff.longitude.toString(),
   };

   Map rideInfoMap =
   {
     "driver_id": "waiting",
     "payment_method": "cash",
     "pickUp": pickUpLocMap,
     "dropOff": dropOffLocMap,
     "created_at": DateTime.now().toString(),
     "rider_name": userCurrentInfo.name,
     "rider_phone": userCurrentInfo.phone,
     "pickup_address": pickUp.placeName,
     "dropoff_address": dropOff.placeName,
   };

   rideRequestRef.set(rideInfoMap);
 } 

void cancelRideRequest()
{
   rideRequestRef.remove();
} 

void displayRideRequestContainer()
{
  setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });

    saveRideRequest();
}

resetApp()
{
  setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 230.0;

      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      pLineCoordinates.clear();
    });

    locatePosition();
}

void displayRideDetailsContainer() async
{
  await getPlaceDirection();

  setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 240.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = false;
    });
}

void locatePosition() async
{
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  currentPosition = position;

  LatLng latLngPosition = LatLng(position.latitude, position.longitude);
  CameraPosition cameraPosition = new CameraPosition(target: latLngPosition, zoom: 14);
  newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

  String address = await AssistantMethods.searchCoordinateAddress(position, context);
  print("This is your address:: "+ address);
}

 static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Jitney'),
        backgroundColor: Colors.orange,
      ),
      drawer: Container(
        color: white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              //DrawerHeader
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: white,
                    ),
                  child: Row(
                    children: [
                      Image.asset("images/user_icon.png", height: 65.0, width: 65.0),
                      SizedBox(width: 16.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("User name", style: TextStyle(fontSize: 16.0, fontFamily: "Brand-Bold"),),
                          Text("Visit Profile"),
                        ],
                      ),
                    ],
                  ),  
                 ), 
              ),
              DividerWidget(),
              SizedBox(height: 12.0),
              ListTile(
                leading: Icon(Icons.history),
                title: Text("History", style: TextStyle(fontSize: 16.0),),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Visit Profile", style: TextStyle(fontSize: 16.0),),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text("About", style: TextStyle(fontSize: 16.0),),
              ),
              GestureDetector(
                onTap: ()
                {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text("Sign Out", style: TextStyle(fontSize: 16.0),),
                ),
              ),
            ],
          ) ,
          ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            polylines: polylineSet,
            markers: markerSet,
            circles:  circleSet,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                     bottomPaddingOfMap = 265.0;         
                            });

              locatePosition();
            }
           ),

           

           //HamburgerButton for the drawer
           Positioned(
             top: 38.0,
             left: 22.0,
             child: GestureDetector(
               onTap: ()
               {
                  if(drawerOpen)
                  {
                    scaffoldKey.currentState.openDrawer();
                  }
                  else
                  {
                    resetApp();
                  }
               },
               child: Container(
                 decoration: BoxDecoration(
                   color: white,
                   borderRadius: BorderRadius.circular(22.0),
                   boxShadow: [
                     BoxShadow(
                       color: black,
                       blurRadius: 6.0,
                       spreadRadius: 0.6,
                       offset: Offset(
                         0.7, 0.7
                       ),
                     ),
                   ]
                 ),
                 child: CircleAvatar(
                   backgroundColor: white,
                   child: Icon((drawerOpen) ? Icons.menu : Icons.close, color: black,),
                   radius: 20.0,
                 ),
               ),
             ),
           ),


          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                  height: searchContainerHeight,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18) ),
                    boxShadow: [
                      BoxShadow(
                        color: orange,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6.0,),
                        Text("Hello there", style: TextStyle(fontSize: 12.0),),
                        Text("Where to", style: TextStyle(fontSize: 20.0,fontFamily: "Brand-Bold"),),
                        SizedBox(height: 20.0,),
                        GestureDetector(
                          onTap: () async
                          {
                            var res = await Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));

                            if(res == "obtainDirection")
                            {
                              displayRideDetailsContainer();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                                BoxShadow(
                                  color: black,
                                  blurRadius: 6.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7),
                                 ),
                                ],
                               ),

                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                Icon(Icons.search, color: Colors.blue,),
                                SizedBox(width: 10.0,),
                                Text("Search drop-off location"),
                                 ],
                                 ),
                            ),   

                               ),
                        ),
                        SizedBox(height: 24.0),
                        Row(
                          children: [
                            Icon(Icons.home, color: grey,),
                            SizedBox(width: 12.0,),
                            Column(
                              crossAxisAlignment:CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Provider.of<AppData>(context).pickUpLocation != null
                                    ? Provider.of<AppData>(context).pickUpLocation
                                    :"Add home"
                                ),
                                SizedBox(height: 5.0),
                                Text("Living home address",style: TextStyle(color: Colors.black54,fontSize: 12.0),),
                              ],

                            )

                          ],
                        ),
                        SizedBox(height: 10.0,),

                        DividerWidget(),

                        SizedBox(height: 10.0,),

                        Row(
                          children: [
                            Icon(Icons.work, color: grey,),
                            SizedBox(width: 12.0,),
                            Column(
                              crossAxisAlignment:CrossAxisAlignment.start,
                              children: [
                                Text("Add work"),
                                SizedBox(height: 5.0),
                                Text("Your office address",style: TextStyle(color: Colors.black54,fontSize: 12.0),),
                              ],

                            )

                          ],
                        )

                      ],
                    ),
                  ),
              ),
            ),
          ),

         Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: AnimatedSize(
            vsync: this,
            curve: Curves.bounceIn,
            duration: new Duration(milliseconds: 160),
            child: Container(
              height: rideDetailsContainerHeight,
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0)),
                boxShadow: [
                  BoxShadow(
                    color: black,
                    blurRadius: 16.0,
                    spreadRadius: 0.6,
                    offset: Offset(0.7, 0.7),
                  ),
                ]
              ),
              child: Padding(
                padding:  EdgeInsets.symmetric(vertical: 17.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.tealAccent[100],
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Image.asset("images/taxi.png", height: 70.0, width: 80.0),
                            SizedBox(width: 16.0,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Car", style: TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold"),
                                ),
                                Text(
                                  ((tripDirectionDetails != null) ? tripDirectionDetails.distanceText : ''), style: TextStyle(fontSize: 18.0, color: grey),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Text(
                                  ((tripDirectionDetails != null) ? '\$${AssistantMethods.calculateFares(tripDirectionDetails)}': ''), style: TextStyle(fontFamily: "Brand-Bold"),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0,),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.moneyCheckAlt, size: 18.0, color: Colors.black54),
                          SizedBox(width: 6.0,),
                          Text("Cash"),
                          SizedBox(width: 6.0),
                          Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16.0,),

                        ],
                      ),
                      ),

                    SizedBox(height: 24.0,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      // ignore: deprecated_member_use
                      child: RaisedButton(
                        onPressed: ()
                        {
                           displayRideRequestContainer();
                        }, 
                        color: Theme.of(context).accentColor,
                        child: Padding(
                          padding: EdgeInsets.all(17.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Request", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: white),),
                              Icon(FontAwesomeIcons.taxi, size:26.0, color:white),
                            ],
                          ),
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ),
         ),
        
         Positioned(
           top: 0.0,
           left: 0.0,
           right: 0.0,
           child: Container(
             decoration: BoxDecoration(
               borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0),),
               color: white,
               boxShadow: [
                 BoxShadow(
                   color: black,
                   blurRadius: 16.0,
                   spreadRadius: 0.6,
                   offset: Offset(0.7, 0.7),    
                 ),
               ],
             ),
             height: requestRideContainerHeight,
             child: Padding(
               padding: const EdgeInsets.all(30.0),
               child: Column(
                 children: [
                    SizedBox(height: 12.0,),

                    SizedBox(
                      height: double.infinity,
                      child: WavyAnimatedTextKit(
                          textStyle: TextStyle(
                                 fontSize: 40.0,
                                 fontWeight: FontWeight.bold,
                                 fontFamily: "Canterbury"
                            ),
                             text: [
                                  "Requesting your ride...",
                                  "please wait...",
                                  "Finding your driver",                              
                             ],
                           isRepeatingAnimation: true,
                          ),
                    ),
                    SizedBox(height: 22.0,),

                    GestureDetector(
                      onTap: ()
                      {
                        cancelRideRequest();
                        resetApp();
                      },
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(26.0),
                          border: Border.all(width: 2.0, color: Colors.black54),
                        ),
                        child: Icon(Icons.close, size: 26.0),
                      ),
                    ),

                    SizedBox(height: 10.0,),

                    Container(
                      width: double.infinity,
                      child: Text("Cancel Ride", textAlign: TextAlign.center,
                      style:  TextStyle(fontSize: 12.0),
                      ),
                    ),

                 ],
               ),
             ),
           ),
         ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async
  {
    var initialPos = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
      context: context, 
      builder: (BuildContext content) => ProgressDialog(message: "Please wait...",)
    );
    var details = await AssistantMethods.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);

    setState(() {
          tripDirectionDetails = details;
        });
    Navigator.pop(context);

    print("This is encoded points :");
    print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult = polylinePoints.decodePolyline(details.encodedPoints);
     
    pLineCoordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty)
    {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng)
      {
         pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
     Polyline polyline = Polyline(
      color: orange,
      polylineId: PolylineId("PolylineID"),
      jointType: JointType.round,
      points: pLineCoordinates,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
      );

      polylineSet.add(polyline);
        });

      LatLngBounds latLngBounds;
      if(pickUpLatLng.latitude > dropOffLatLng.latitude && pickUpLatLng.longitude > dropOffLatLng.longitude)
      {
        latLngBounds = LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
      }
      else if(pickUpLatLng.longitude> dropOffLatLng.longitude)
      {
        latLngBounds = LatLngBounds(southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude), 
        northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
      }
      else if(pickUpLatLng.latitude > dropOffLatLng.latitude)
      {
        latLngBounds = LatLngBounds(southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude), 
        northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
      } 
      else 
      {
        latLngBounds = LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
      }

      newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

      Marker pickUpLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: initialPos.placeName, snippet: "My location"),
        position:  pickUpLatLng,
        markerId: MarkerId("pickUpId"),
      );

      Marker dropOffLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: finalPos.placeName, snippet: "Drop-off location"),
        position:  dropOffLatLng,
        markerId: MarkerId("dropOffId"),
      );

      setState(() {
              markerSet.add(pickUpLocMarker);
              markerSet.add(dropOffLocMarker);
            });

      Circle pickUpLocCircle = Circle(
        fillColor: Colors.blue,
        center: pickUpLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.blueAccent,
        circleId: CircleId("pickUpId")
      );

      Circle dropOffLocCircle = Circle(
        fillColor: Colors.red,
        center: dropOffLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.redAccent,
        circleId: CircleId("dropOffId"),
      ); 

      setState(() {
              circleSet.add(pickUpLocCircle);
              circleSet.add(dropOffLocCircle);
            }); 
  }

}