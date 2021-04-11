import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jitney_cabs_driver/src/assistants/assistantMethods.dart';
import 'package:jitney_cabs_driver/src/helpers/configMaps.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';
import 'package:jitney_cabs_driver/src/helpers/toastDisplay.dart';
import 'package:jitney_cabs_driver/src/models/rideDetails.dart';
import 'package:jitney_cabs_driver/main.dart';
import 'package:jitney_cabs_driver/src/screens/newRideScreen.dart';

class NotificationDialog extends StatelessWidget
{
  final RideDetails rideDetails;
  NotificationDialog({this.rideDetails});

  @override
  Widget build (BuildContext context)
  {
     return Dialog(
       shape:RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(12)),
         backgroundColor: Colors.transparent,
         elevation: 1.0,
         child: Container(
           margin: EdgeInsets.all(5.0),
           width: double.infinity,
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(5.0),
           ),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               SizedBox(height: 18.0,),
               Image.asset("images\taxi.png", width: 120.0,),
               SizedBox(height: 18.0,),
               Text("New Ride Request", style: TextStyle(fontSize: 18.0)),
               SizedBox(height: 30.0,),
               Padding(
                 padding: EdgeInsets.all(18.0),
                 child: Column(
                   children: [
                    Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Image.asset("images\pickicon.png", width: 16.0, height: 16.0),
                         SizedBox(width: 20.0,),
                         Expanded(
                           child: Container(child: Text(rideDetails.pickup_address, style: TextStyle(fontSize: 18.0),)),
                         ),
                         
                       ],
                     ),

                     SizedBox(height:15.0),

                    Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Image.asset("images\desticon.png", width: 16.0, height: 16.0),
                         SizedBox(width: 20.0,),
                         Expanded(
                           child: Container(child: Text(rideDetails.dropoff_address, style: TextStyle(fontSize: 18.0),)),
                           ),
                         
                       ],
                     ),

                     SizedBox(height:15.0),


                   ],
                 ),
                 ),
                 SizedBox(height:20.0),
                 Divider(height: 2.0, color: grey,),
                 SizedBox(height:8.0),
                 
                 Padding(
                   padding: EdgeInsets.all(20.0),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       // ignore: deprecated_member_use
                       FlatButton(
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(18.0),
                           side: BorderSide(color: red),
                         ),
                        color: white,
                        textColor: red,
                        padding: EdgeInsets.all(8.0), 
                         onPressed: () {
                           assetsAudioPlayer.stop();
                           Navigator.pop(context);
                         }, 
                         child: Text(
                           "Cancel".toUpperCase(),
                           style: TextStyle(
                             fontSize: 14.0,
                           ),
                         ),
                         ),

                       SizedBox(width:25.0),

                       // ignore: deprecated_member_use
                       RaisedButton(
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(18.0),
                           side: BorderSide(color: Colors.green),
                         ),
                         onPressed: (){
                           assetsAudioPlayer.stop();
                           checkAvailabilityOfRide(context);
                         },
                         color: Colors.green,
                         textColor: white,
                         child: Text(
                           "Accept".toUpperCase(),
                           style:TextStyle(fontSize: 14.0)
                         ),

                       ),

                     ],
                   ),
                 ),
                 SizedBox(height: 8.0),
             ],
             ),
         ),
     );
  }

  void checkAvailabilityOfRide(context)
  {
    rideRequestRef.once().then((DataSnapshot dataSnapShot)
    {
    Navigator.pop(context);
    String theRideId = " ";
    if(dataSnapShot.value != null)
    {
       theRideId = dataSnapShot.value.toString();
      }
      else
      {
        displayToastMessage("Ride does not exist", context);
      }
     if(theRideId == rideDetails.ride_request_id)
     {
      rideRequestRef.set("accepted");
      AssistantMethods.disableHomeTabLiveLocationUpdates();
      Navigator.push(context, MaterialPageRoute(builder: (context)=> NewRideScreen(rideDetails: rideDetails)));
     }
     else if(theRideId == "cancelled")
     {
       displayToastMessage("Ride was cancelled", context);
     }
     else if(theRideId == "timeout")
     {
       displayToastMessage("Ride has timed out", context);
     }
     else
      {
        displayToastMessage("Ride does not exist", context);
      }
    });
    
  }
}