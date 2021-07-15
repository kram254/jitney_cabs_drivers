import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jitney_cabs_driver/src/assistants/assistantMethods.dart';
import 'package:jitney_cabs_driver/src/assistants/mapKitAssistant.dart';
import 'package:jitney_cabs_driver/src/helpers/configMaps.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';
import 'package:jitney_cabs_driver/src/models/rideDetails.dart';
import 'package:jitney_cabs_driver/src/widgets/collectFareDialog.dart';
import 'package:jitney_cabs_driver/src/widgets/progressDialog.dart';
import 'package:jitney_cabs_driver/main.dart';

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
 Set <Marker> markerSet =  Set<Marker>();
 Set <Circle> circleSet =  Set<Circle>();
 Set <Polyline> polyLineSet = Set<Polyline>();
 List <LatLng> polyLineCordinates = [];
 PolylinePoints polylinePoints = PolylinePoints();
 double mapPaddingFromBottom = 0;
 var geolocator = Geolocator();
 var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
 BitmapDescriptor animatingMarkerIcon;
 Position myPosition;
 String status = "accepted";
 String durationRide = "";
 bool isRequestingDirection = false;
 String btnTitle = "Arrived";
 Color btnColor = Colors.blueAccent;
 Timer timer;
 int durationCounter =0;

 @override
   void initState() {
     super.initState();
     acceptRideRequest();
   }

 void createIconMarker()
  {
    if( animatingMarkerIcon == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2, 2));
      //adding the drivers car image icon
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car_android.png")
      .then((value)
      {
        animatingMarkerIcon = value;
      } );

    }
  } 

  void getRideLiveLocationUpdates()
  {
    LatLng oldPos = LatLng(0, 0);

    rideStreamSubscription = Geolocator.getPositionStream().listen((Position position)
    {
      currentPosition = position;
      myPosition = position;
      LatLng mPosition = LatLng(position.latitude, position.longitude);

      var rot = MapKitAssistant.getMarkerRotation(oldPos.latitude, oldPos.longitude, myPosition.latitude, myPosition.longitude);
      
      Marker animatingMarker = Marker(
        markerId: MarkerId("animating"),
        position: mPosition,
        rotation: rot,
        icon: animatingMarkerIcon,
        infoWindow: InfoWindow(title: "Current Location"),

      );

      setState(() {
           CameraPosition cameraPostion = new CameraPosition(target: mPosition, zoom: 17);
           newRideGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPostion));

           markerSet.removeWhere((marker) => marker.markerId.value == "animating");
           markerSet.add(animatingMarker);
      });

      oldPos = mPosition;
      updateRideDetails();
      
      String rideRequestId = widget.rideDetails.ride_request_id;
      Map locMap = {
        "latitude":currentPosition.latitude.toString(),
        "longitude": currentPosition.longitude.toString(),
    };
    newRequestsRef.child(rideRequestId).child("driver_location").set(locMap);

     });
  }

  @override
  Widget build(BuildContext context) 
  {
    createIconMarker();
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: NewRideScreen._kGooglePlex,
            myLocationEnabled: true,
            markers: markerSet,
            circles: circleSet,
            polylines: polyLineSet,
            //zoomControlsEnabled: true,
            //zoomGesturesEnabled: true,
            
            onMapCreated: (GoogleMapController controller) async
            {
              _controllerGoogleMap.complete(controller);
              newRideGoogleMapController = controller;

              setState(() 
              {
                mapPaddingFromBottom = 265.0;
              });

              var currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickUpLatLng = widget.rideDetails.pickup;

              await getPlaceDirection(currentLatLng, pickUpLatLng);
              
              getRideLiveLocationUpdates();
             
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
                     Text(durationRide,
                     style: TextStyle(fontSize: 14, color: Colors.deepPurple)
                     ),
                     SizedBox(height: 6.0,),

                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(widget.rideDetails.rider_name, 
                         style: TextStyle(fontSize: 24.0),),
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
                             widget.rideDetails.pickup_address,
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
                             widget.rideDetails.dropoff_address,
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
                           onPressed: () async
                           {
                              if(status == "accepted")
                              {
                                status = "arrived";
                                String rideRequestId = widget.rideDetails.ride_request_id;
                                newRequestsRef.child(rideRequestId).child("status").set(status);

                                setState(() {
                                    btnTitle = "Start Trip";
                                    btnColor = Colors.purple;                                                                  
                                            });

                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) => ProgressDialog(message: "Please wait... ",)
                                    );

                                  await getPlaceDirection(widget.rideDetails.pickup, widget.rideDetails.dropoff); 

                              }
                              else if(status == "arrived")
                              {
                                status = "on ride";
                                String rideRequestId = widget.rideDetails.ride_request_id;
                                newRequestsRef.child(rideRequestId).child("status").set(status);

                                setState(() {
                                    btnTitle = "End Trip";
                                    btnColor = red;                                                                  
                                            });

                                     initTimer();     

                              }
                              else if(status == "on ride")
                              {
                                endTheTrip();
                              }
                           },
                           color: btnColor,
                           child: Padding(
                             padding: EdgeInsets.all(17.0),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Text(btnTitle, 
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

   Future<void> getPlaceDirection(LatLng pickUpLatLng, LatLng dropOffLatLng) async
  {
    showDialog(
      context: context, 
      builder: (BuildContext content) => ProgressDialog(message: "Please wait...",)
    );
    var details = await AssistantMethods.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);

    Navigator.pop(context);

    print("This is encoded points :");
    print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult = polylinePoints.decodePolyline(details.encodedPoints);
     
    polyLineCordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty)
    {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng)
      {
         polyLineCordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
     Polyline polyline = Polyline(
      color: orange,
      polylineId: PolylineId("PolylineID"),
      jointType: JointType.round,
      points: polyLineCordinates,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
      );

      polyLineSet.add(polyline);
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

      newRideGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

      Marker pickUpLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position:  pickUpLatLng,
        markerId: MarkerId("pickUpId"),
      );

      Marker dropOffLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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

  void acceptRideRequest()
  {
    String rideRequestId = widget.rideDetails.ride_request_id;
    newRequestsRef.child(rideRequestId).child("status").set("accepted");
    newRequestsRef.child(rideRequestId).child("driver_name").set("driversInformation.name");
    newRequestsRef.child(rideRequestId).child("driver_phone").set("driversInformation.phone");
    newRequestsRef.child(rideRequestId).child("driver_id").set("driversInformation.id");
    newRequestsRef.child(rideRequestId).child("car_details").set('${driversInformation.car_color}) - ${driversInformation.car_model}');

    Map locMap = {
        "latitude":currentPosition.latitude.toString(),
        "longitude": currentPosition.longitude.toString(),
    };
    newRequestsRef.child(rideRequestId).child("driver_location").set(locMap);

    driversRef.child(currentfirebaseUser.uid).child("history").child(rideRequestId).set(true);
  }

  void updateRideDetails() async
  {
    if(isRequestingDirection == false)
    {
     isRequestingDirection = true;
     if(myPosition = null)
    {
      return;
    }


    var posLatLng = LatLng(myPosition.latitude, myPosition.longitude);
    LatLng destinationLatLng;
    if(status == "accepted")
    {
      destinationLatLng = widget.rideDetails.pickup;
    }
    else
    {
      destinationLatLng = widget.rideDetails.dropoff;
    }

    var directionDetails =  await AssistantMethods.obtainPlaceDirectionDetails(posLatLng, destinationLatLng);
    if(directionDetails != null)
    {
      setState(() {
              durationRide = directionDetails.durationText;
            });
    }
    isRequestingDirection = false;
    }
    }

    void initTimer()
    {
      const interval = Duration(seconds: 1);
      timer = Timer.periodic(interval, (timer)
      {
        durationCounter = durationCounter+1;
      }
      );
    }

    void endTheTrip() async
    {
      timer.cancel();

      showDialog(
      context: context, 
      builder: (BuildContext content) => ProgressDialog(message: "Please wait...",)
    );
    
    var currentLatLng = LatLng(myPosition.latitude,myPosition.longitude);
    var directionDetails = await AssistantMethods.obtainPlaceDirectionDetails(widget.rideDetails.pickup, currentLatLng);
    Navigator.pop(context);

    int fareAmount = AssistantMethods.calculateFares(directionDetails);

    String rideRequestId = widget.rideDetails.ride_request_id;
    newRequestsRef.child(rideRequestId).child("fares").set(fareAmount.toString());
    newRequestsRef.child(rideRequestId).child("status").set("ended");
    rideStreamSubscription.cancel();

    showDialog(
      context: context, 
      builder: (BuildContext content) => CollectFareDialog(paymentMethod: widget.rideDetails.payment_method, fareAmount: fareAmount,),
    );

    saveEarnings(fareAmount);
    }
     
     void saveEarnings(int fareAmount)
     {
       driversRef.child(currentfirebaseUser.uid).child("earnings").once().then((DataSnapshot dataSnapShot)
       {
         if( dataSnapShot.value == null)
         {
           double oldEarnings = double.parse(dataSnapShot.value.toString());
           double totalEarnings = fareAmount + oldEarnings;

           driversRef.child(currentfirebaseUser.uid).child("earnings").set(totalEarnings.toStringAsFixed(2));

         }
         else
         {
           double totalEarnings = fareAmount.toDouble();

           //saving to the database
           driversRef.child(currentfirebaseUser.uid).child("earnings").set(totalEarnings.toStringAsFixed(2));
         }
         
       });
     }
}