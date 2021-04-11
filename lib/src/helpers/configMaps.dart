import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jitney_cabs_driver/src/models/drivers.dart';
import 'package:jitney_cabs_driver/src/models/users.dart';

String mapKey = "AIzaSyCG1-AWjvpqmmq1HaLggAPiG1YV3u0ak8Y";

User firebaseUser; 
Users userCurrentInfo;
User currentfirebaseUser;
StreamSubscription<Position> homeTabStreamSubscription;
StreamSubscription<Position> rideStreamSubscription;
final assetsAudioPlayer = AssetsAudioPlayer();
Position currentPosition;
Drivers driversInformation;