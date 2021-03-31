import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jitney_cabs_driver/main.dart';
import 'package:jitney_cabs_driver/src/helpers/configMaps.dart';

class PushNotificationService
{

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future <String>  getToken () async
  {
    String token = await firebaseMessaging.getToken();
    print("This is the token ::");
    print(token);
    driversRef.child(currentfirebaseUser.uid).child("token").set(token);

    firebaseMessaging.subscribeToTopic("alldrivers");
    firebaseMessaging.subscribeToTopic("allusers");
  }
}