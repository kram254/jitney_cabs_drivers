import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jitney_cabs_driver/src/helpers/configMaps.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class RatingsTab extends StatefulWidget {
  @override
  _RatingsTabState createState() => _RatingsTabState();
}

class _RatingsTabState extends State<RatingsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          ),
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(5.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(5.0),
                   
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 22.0,),
    
              Text("Your Rating",
              style: TextStyle(color: Colors.black54, fontSize: 20.0, fontFamily: "Brand bold"),
              ),
    
              SizedBox(height: 22.0,),
    
              Divider(),
    
              SizedBox(height: 16.0,),

    
              
              SmoothStarRating(
                rating: starCounter,
                color: Colors.yellow,
                allowHalfRating: true,
                starCount: 5,
                size: 45,
                isReadOnly: true,
                
              ),
    
              SizedBox(height: 14.0),

              Text(title, style: TextStyle(fontSize: 55.0, fontFamily: "Brand bold", color: Colors.grey)),
              SizedBox(height:16.0),
    
              
            ],
          ),
        ),  
      ),
    );
  }
}