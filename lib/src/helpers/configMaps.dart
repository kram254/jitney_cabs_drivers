import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jitney_cabs_driver/src/models/drivers.dart';
import 'package:jitney_cabs_driver/src/models/users.dart';

String mapKey = "AIzaSyCCkK4ZL7B_cnaqeTsBAt2ypF6iJLtQA_g";

User firebaseUser; 
Users userCurrentInfo;
User currentfirebaseUser;
StreamSubscription<Position> homeTabStreamSubscription;
StreamSubscription<Position> rideStreamSubscription;
final assetsAudioPlayer = AssetsAudioPlayer();
Position currentPosition;
Drivers driversInformation;
String title = " ";
double starCounter = 0.0;
String rideType = " "; 