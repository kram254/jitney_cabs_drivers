import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jitney_cabs_driver/main.dart';
import 'package:jitney_cabs_driver/src/helpers/configMaps.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';
import 'package:jitney_cabs_driver/src/helpers/toastDisplay.dart';
import 'package:jitney_cabs_driver/src/screens/carInfoScreen.dart';
import 'package:jitney_cabs_driver/src/screens/home.dart';
import 'package:jitney_cabs_driver/src/screens/loginScreen.dart';
import 'package:jitney_cabs_driver/src/widgets/progressDialog.dart';

class RegistrationScreen extends StatelessWidget {
   static const String idScreen = "register";

   TextEditingController nameTextEditingController = TextEditingController();
   TextEditingController emailTextEditingController = TextEditingController();
   TextEditingController phoneTextEditingController = TextEditingController();
   TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 45.0),
              Image(
                image: AssetImage("images/logo3B.png"),
                height: 350,
                width: 350,
                alignment: Alignment.center,
                ),
              SizedBox(height: 5.0),  
              Text("SignUp as a Driver",
              style: TextStyle(fontSize:24.0, color: grey, fontFamily: "Brand Bold"),
              ),
              
              Padding(padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                   SizedBox(height: 5.0),
                   TextField(
                   controller: nameTextEditingController,
                   keyboardType: TextInputType.text,
                   decoration: InputDecoration(
                   labelText: 'Name',
                   labelStyle: TextStyle(fontSize: 14.0),
                   hintStyle: TextStyle(color: grey, fontSize: 14.0)
                 ),
                 ),  

                   SizedBox(height: 5.0),
                   TextField(
                     controller: emailTextEditingController,
                   keyboardType: TextInputType.emailAddress,
                   decoration: InputDecoration(
                   labelText: 'Email',
                   labelStyle: TextStyle(fontSize: 14.0),
                   hintStyle: TextStyle(color: grey, fontSize: 14.0)
                 ),
                 ),

                  SizedBox(height: 5.0),
                   TextField(
                     controller: phoneTextEditingController,
                   keyboardType: TextInputType.phone,
                   decoration: InputDecoration(
                   labelText: 'Phone',
                   labelStyle: TextStyle(fontSize: 14.0),
                   hintStyle: TextStyle(color: grey, fontSize: 14.0)
                 ),
                 ),

                   SizedBox(height: 5.0),
                   TextField(
                     controller: passwordTextEditingController,
                   obscureText: true,
                   decoration: InputDecoration(
                   labelText: 'Password',
                   labelStyle: TextStyle(fontSize: 14.0),
                   hintStyle: TextStyle(color: grey, fontSize: 14.0)
                 ),
                 ),

                 SizedBox(height: 5.0),
                 ElevatedButton(
                   style: ButtonStyle(),
                    onPressed:()
                    {
                     if(nameTextEditingController.text.length < 3)
                     {
                        displayToastMessage("name must contain more than 3 characters", context);
                     } 
                     else if(!emailTextEditingController.text.contains("@"))
                     {
                        displayToastMessage("Please enter a valid Email address", context);
                     } 
                     else if(phoneTextEditingController.text.isEmpty)
                     {
                        displayToastMessage("Please enter your mobile number", context);
                     }
                     else if(passwordTextEditingController.text.length < 6)
                     {
                        displayToastMessage("Password must be atleast 6 characters", context);
                     }
                     else 
                     {
                         registerNewUser(context);
                     }

                    },
                    child: Container(
                      height: 50.0,
                      child: Center(
                        child:Text(
                          'Create Account', 
                          style: TextStyle(color: black, fontSize: 13.0 , fontFamily: "Brand Bold")), 
                      ),
                    ),
                    
                    
                      
                    ),
                 
                  ],
                ),
              ),
             TextButton(
               onPressed: ()
               {
                 Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);        
               }, 
               child: Text("Already have an account, Login here",
               style: TextStyle(color: red, fontSize: 13.0, fontFamily: "Brand Bold" ),
               ),
             )
              
            ],
          ),
        ),
      ), 
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void registerNewUser(BuildContext context)async 
  {
     
     showDialog(
        context: context, 
        barrierDismissible: false,
        builder:(BuildContext context)
        {
          return ProgressDialog(message: "Jitney is registering...",);
        }
        );

     final User _firebaseUser = (await _firebaseAuth
     .createUserWithEmailAndPassword(
     email: emailTextEditingController.text, 
     password: passwordTextEditingController.text).catchError((errMsg)
     {
       Navigator.pop(context);
       displayToastMessage("Error: "+ errMsg.toString(), context);
     } 
     )).user;

     if(_firebaseUser != null)
     {
     // save user details to database
      
      Map userDataMap = 
      {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };

      driversRef.child(_firebaseUser.uid).set(userDataMap);

      currentfirebaseUser = _firebaseUser;

      displayToastMessage("Congratulations, welcome to Jitney.", context);

      Navigator.pushNamed(context, CarInfoScreen.idScreen);

     }
     else
     {
       Navigator.pop(context);
       // display the error message
       displayToastMessage("New user not created. Please try again.", context);
     } 
  }  

}