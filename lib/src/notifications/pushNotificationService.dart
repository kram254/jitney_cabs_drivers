import 'dart:io' show Platform;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jitney_cabs_driver/main.dart';
import 'package:jitney_cabs_driver/src/helpers/configMaps.dart';
import 'package:jitney_cabs_driver/src/models/rideDetails.dart';
import 'package:jitney_cabs_driver/src/notifications/notificationDialog.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class PushNotificationService
{

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  

  // Future initialize (context) async
  // {
  //   firebaseMessaging.configure(
  //     onMessage:(Map<String, dynamic>message) async{
  //       retrieveRideRequestInfo(getRideRequestId(message), context);
  //     },
  //     onLanch:(Map<String, dynamic>message) async{
  //       retrieveRideRequestInfo(getRideRequestId(message), context);
  //     },
  //     onResume:(Map<String, dynamic>message) async{
  //       retrieveRideRequestInfo(getRideRequestId(message), context);
  //     },
  //   ); 
   
  //  }


  Future <String>  getToken () async
  {
    String token = await firebaseMessaging.getToken();
    print("This is the token ::");
    print(token);
    driversRef.child(currentfirebaseUser.uid).child("token").set(token);

    firebaseMessaging.subscribeToTopic("alldrivers");
    firebaseMessaging.subscribeToTopic("allusers");

    return token;
  }

  String getRideRequestId(Map<String, dynamic> message)
  {
    String rideRequestId = " ";
    if(Platform.isAndroid)
    {
       rideRequestId = message['data']['ride_request_id'];
    }
    else
    {
       rideRequestId = message['ride_request_id'];
    }
    return rideRequestId;
  }

  //method to fetch new ride requests
  void retrieveRideRequestInfo(String rideRequestId, BuildContext context)
  {
     newRequestsRef.child(rideRequestId).once().then((DataSnapshot dataSnapShot)
     {
        if(dataSnapShot.value != null)
        {

          assetsAudioPlayer.open(Audio("sounds/alert.mp3"));
          assetsAudioPlayer.play();

          double pickUpLocationLat = double.parse(dataSnapShot.value['pickup']['latitude'].toString());
          double pickUpLocationLng = double.parse(dataSnapShot.value['pickup']['latitude'].toString());
          String pickUpAddress = dataSnapShot.value['pickup_address'].toString();

          double dropOffLocationLat = double.parse(dataSnapShot.value['dropoff']['latitude'].toString());
          double dropOffLocationLng = double.parse(dataSnapShot.value['dropoff']['latitude'].toString());
          String dropOffAddress = dataSnapShot.value['dropoff_address'].toString();

          String paymentMethod = dataSnapShot.value['payment_method'].toString();
          String rider_name = dataSnapShot.value['rider_name'];
          String rider_phone = dataSnapShot.value['rider_phone'];

          RideDetails rideDetails = RideDetails();
          rideDetails.ride_request_id = rideRequestId;
          rideDetails.pickup_address = pickUpAddress;
          rideDetails.dropoff_address = dropOffAddress;
          rideDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
          rideDetails.dropoff = LatLng(dropOffLocationLat, dropOffLocationLng);
          rideDetails.payment_method = paymentMethod;
          rideDetails.rider_name = rider_name;
          rideDetails.rider_phone = rider_phone;

          showDialog(
            context: context,
            barrierDismissible:  false,
            builder:(BuildContext context) => NotificationDialog(rideDetails: rideDetails,),
          );
        }
     });
  }
}