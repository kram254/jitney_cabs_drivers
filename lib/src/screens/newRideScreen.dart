import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jitney_cabs_driver/src/assistants/assistantMethods.dart';
import 'package:jitney_cabs_driver/src/helpers/configMaps.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';
import 'package:jitney_cabs_driver/src/models/rideDetails.dart';
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

 @override
   void initState() {
     super.initState();
     acceptRideRequest();
   }


  @override
  Widget build(BuildContext context) {
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
  }
}