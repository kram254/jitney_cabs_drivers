import 'package:flutter/material.dart';
import 'package:jitney_cabs_driver/src/assistants/assistantMethods.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';

class CollectFareDialog extends StatelessWidget {

  final  String paymentMethod;
  final int fareAmount;

  CollectFareDialog({this.fareAmount, this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    return Dialog(
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

            Text("Trip Fare"),

            SizedBox(height: 22.0,),

            Divider(),

            SizedBox(height: 16.0,),

            Text("\$$fareAmount", style: TextStyle(fontSize: 55.0),),

            SizedBox(height: 16.0,),

            Padding(
              padding: const EdgeInsets.symmetric( horizontal: 20.0),
              child: Text("Total amount for the trip charged to rider", textAlign: TextAlign.center,),
            ),

            SizedBox(height: 30.0),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              // ignore: deprecated_member_use
              child: RaisedButton(
                onPressed: () async
                {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  AssistantMethods.enableHomeTabLiveLocationUpdates();

                },
                color: Colors.deepPurpleAccent,
                child: Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Text("Collect cash", 
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: white),
                      ),
                      Icon(Icons.attach_money_outlined, color: white, size: 26.0,),
                    ],
                  ),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
          ],
        ),
      ),  
    );
  }
}