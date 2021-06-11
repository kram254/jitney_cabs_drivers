import 'package:flutter/material.dart';
import 'package:jitney_cabs_driver/src/assistants/assistantMethods.dart';
import 'package:jitney_cabs_driver/src/models/history.dart';

class HistoryItem extends StatelessWidget {
  final History history;
  
  HistoryItem({this.history});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Container(
                   child:Row(
                    children: [
                      Image.asset("images/pickicon.png", height: 16, width: 16,),
                      SizedBox(width: 18),
                      Expanded(child: Container(child: Text(history.pickUp, overflow: TextOverflow.ellipsis, style: TextStyle(),),)),
                      SizedBox(width: 5,),

                      Text('\$${history.fares}', style: TextStyle(fontFamily: "Brand bold", fontSize: 16.0, color: Colors.black87),),
                    ],
                   ),
                ),

                SizedBox(height: 8),

                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Image.asset("images/desticon.png", height: 16, width: 16,),
                    SizedBox(width: 18.0,),

                    Text(history.dropOff, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18),),
                  
                    
                  ],
                ),
                SizedBox(height: 15.0),
                Text(AssistantMethods.formatTripDate(history.createdAt),style: TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}