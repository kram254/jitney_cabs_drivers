import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jitney_cabs_driver/src/helpers/configMaps.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';
import 'package:jitney_cabs_driver/src/models/rideDetails.dart';
import 'package:jitney_cabs_driver/src/notifications/notificationDialog.dart';
import 'package:jitney_cabs_driver/src/providers/appData.dart';
import 'package:jitney_cabs_driver/src/screens/RegistrationScreen.dart';
import 'package:jitney_cabs_driver/src/screens/carInfoScreen.dart';
import 'package:jitney_cabs_driver/src/screens/home.dart';
import 'package:jitney_cabs_driver/src/screens/loginScreen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
  playSound:true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin ();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message received: ${message.messageId}');
}

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  currentfirebaseUser = FirebaseAuth.instance.currentUser;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );    
  runApp(MyApp());
}

DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users");
DatabaseReference driversRef = FirebaseDatabase.instance.reference().child("drivers");
DatabaseReference newRequestsRef = FirebaseDatabase.instance.reference().child("Ride Requests");
DatabaseReference rideRequestRef = FirebaseDatabase.instance.reference().child("drivers").child(currentfirebaseUser.uid).child("newRide");


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String token;
  @override
    void initState() {
      // TODO: implement initState
      super.initState();
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                color: Colors.blue,
                icon: android?.smallIcon,
              ),
            )
            );
      }
    });
      
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        RemoteNotification notification = message.notification;
        AndroidNotification android = message.notification?.android;
        if (notification != null && android != null) {
          showDialog(
            context: context,
            builder: (_){
              return AlertDialog(
                title:Text(notification.title),
                content: SingleChildScrollView(
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body),
                    ],

                  ),
                ),
              );
            }
          );
       }
    });
    
    getToken();

    }

  @override
   Widget build(BuildContext context) {
     return ChangeNotifierProvider(
       create: (context) => AppData(),
       child: MaterialApp(
         title: 'J!tney Driver',     
         theme: ThemeData(
           //fontFamily: "Brand Bold",
           primarySwatch: Colors.orange,
           visualDensity: VisualDensity.adaptivePlatformDensity,
         ),
         initialRoute: FirebaseAuth.instance.currentUser == null ? LoginScreen.idScreen : HomeScreen.idScreen,
         routes:
         {
            RegistrationScreen.idScreen:(context)=> RegistrationScreen(),
            LoginScreen.idScreen:(context)=> LoginScreen(),
            HomeScreen.idScreen:(context)=> HomeScreen(),
            CarInfoScreen.idScreen:(context)=> CarInfoScreen(),
         },
         debugShowCheckedModeBanner: false,
       ),
     );
   }


   getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    setState(() {
          token = token;
        });
    print(token);
    driversRef.child(currentfirebaseUser.uid).child("token").set(token);

    await FirebaseMessaging.instance.subscribeToTopic('alldrivers');
    await FirebaseMessaging.instance.subscribeToTopic('allusers');
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
            barrierDismissible: false,
            builder:(BuildContext context) => NotificationDialog(rideDetails: rideDetails,),
          );
        }
     });
  }

  }


// class MyApp extends StatelessWidget {
      
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => AppData(),
//       child: MaterialApp(
//         title: 'J!tney Driver',
//         theme: ThemeData(
//           //fontFamily: "Brand Bold",
//           primarySwatch: orange,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//         ),
//         initialRoute: FirebaseAuth.instance.currentUser == null ? LoginScreen.idScreen : HomeScreen.idScreen,
//         routes:
//         {
//            RegistrationScreen.idScreen:(context)=> RegistrationScreen(),
//            LoginScreen.idScreen:(context)=> LoginScreen(),
//            HomeScreen.idScreen:(context)=> HomeScreen(),
//            CarInfoScreen.idScreen:(context)=> CarInfoScreen(),
//         },
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }

