import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jitney_cabs_driver/main.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';
import 'package:jitney_cabs_driver/src/helpers/toastDisplay.dart';
import 'package:jitney_cabs_driver/src/screens/RegistrationScreen.dart';
import 'package:jitney_cabs_driver/src/screens/home.dart';
import 'package:jitney_cabs_driver/src/widgets/progressDialog.dart';

class LoginScreen extends StatelessWidget {
      static const String idScreen = "login";

      TextEditingController emailTextEditingController = TextEditingController();
      TextEditingController passwordTextEditingController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: orange ,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 45.0),
              Image(
                image: AssetImage("images/logo1.png"),
                height: 350,
                width: 350,
                alignment: Alignment.center,
                ),
              SizedBox(height: 5.0),  
              Text("Login as a Driver",
              style: TextStyle(fontSize:24.0, color: grey, fontFamily: "Brand Bold"),
              ),
              
              Padding(padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
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
                      if(!emailTextEditingController.text.contains("@"))
                     {
                        displayToastMessage("Please enter a valid Email address", context);

                     } else if(passwordTextEditingController.text.isEmpty)
                     {
                        displayToastMessage("Please provide a password", context);
                     }
                     else 
                     {
                        loginAndAuthenticateUser(context);  
                     }
                        
                    },
                    child: Container(
                      height: 50.0,
                      child: Center(
                        child:Text(
                          'Login', 
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
                 Navigator.pushNamedAndRemoveUntil(context, RegistrationScreen.idScreen, (route) => false);
               }, 
               child: Text("Register Here",
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
   void loginAndAuthenticateUser(BuildContext context) async
   {
      showDialog(
        context: context, 
        barrierDismissible: false,
        builder:(BuildContext context)
        {
          return ProgressDialog(message: "Jitney is authenticating you please wait ...",);
        }
        );

     final User _firebaseUser = (await _firebaseAuth.signInWithEmailAndPassword(
       email: emailTextEditingController.text, 
       password: passwordTextEditingController.text).catchError((errMsg)
       {
         Navigator.pop(context);
         displayToastMessage("Error: "+ errMsg.toString(), context);
       })).user;

       if(_firebaseUser != null)
     {
     // save user details to database
      
      driversRef.child(_firebaseUser.uid).once().then((DataSnapshot snap)
      {
        if(snap.value != null)
        {
          Navigator.pushNamedAndRemoveUntil(context, HomeScreen.idScreen, (route) => false);
          displayToastMessage("You're logged in successfully.", context);
        }
        else
        {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToastMessage("This user doesn't exist. Please create new user account", context);
        }
      });
      
      
     }
     else
     {
       Navigator.pop(context);

       // display the error message
       displayToastMessage("Sorry Error occurred, Please try again.", context);
     } 
   }
}