import 'package:flutter/material.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';

class ProgressDialog extends StatelessWidget {

String message;//parameterization
ProgressDialog({this.message});


  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: orange,
      child: Container(
        margin: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(width: 5.0,),
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(black),),
              SizedBox(width: 25.0,),
              Text(message,
              style: TextStyle(color: black, fontSize: 10.0),
              
              )
            ],
          ),
        ),
      )
      
    );
  }
}