import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jitney_cabs_driver/src/providers/appData.dart';
import 'package:jitney_cabs_driver/src/screens/historyScreen.dart';
import 'package:provider/provider.dart';

class EarningsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.black54,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 70),
            child: Column(
              children: [
                Text('Total earnings', style: TextStyle(color: Colors.white,),),
                Text("\$${Provider.of<AppData>(context, listen: false).earnings}", style: TextStyle(color: Colors.white, fontSize: 50, fontFamily: "Brand bold"),),
              ],
            ),
            ),
        ),

        TextButton(
          //padding: EdgeInsets.all(0),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen()));
          }, 
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 18.0),
            child: Row(
              children: [
                Image.asset("images/jitneylux.png",width: 70.0,),
                SizedBox(width: 16,),
                Text("Total trips", style: TextStyle(fontSize: 16.0),),
                Expanded(child: Container(child: Text(Provider.of<AppData>(context, listen: false).countTrips.toString(),
                 textAlign: TextAlign.end, style: TextStyle(fontSize: 18.0,),
                )
                )
                ),
              ],
            ),
            ),
          ),

          Divider(height: 2.0, thickness: 2.0,),
      ],
      
    );
  }
}