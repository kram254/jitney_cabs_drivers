import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';
import 'package:jitney_cabs_driver/src/providers/appData.dart';
import 'package:jitney_cabs_driver/src/screens/RegistrationScreen.dart';
import 'package:jitney_cabs_driver/src/screens/carInfoScreen.dart';
import 'package:jitney_cabs_driver/src/screens/home.dart';
import 'package:jitney_cabs_driver/src/screens/loginScreen.dart';
import 'package:provider/provider.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users");
DatabaseReference driversRef = FirebaseDatabase.instance.reference().child("drivers");

class MyApp extends StatelessWidget {
      
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'J!tney Driver',
        theme: ThemeData(
          //fontFamily: "Brand Bold",
          primarySwatch: orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: HomeScreen.idScreen,
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
}

