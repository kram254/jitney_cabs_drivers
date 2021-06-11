import 'package:flutter/material.dart';
import 'package:jitney_cabs_driver/src/providers/appData.dart';
import 'package:jitney_cabs_driver/src/widgets/historyItem.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        backgroundColor: Colors.black87,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon:  Icon(Icons.keyboard_arrow_left_outlined),
        ),
      ),

      body: ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index)
        {
          return HistoryItem(
            history: Provider.of<AppData>(context, listen: false).tripHistoryDataList[index],
          );
          
        },
        separatorBuilder: (BuildContext context,  int index) => Divider(thickness: 3.0, height: 3.0),
        itemCount: Provider.of<AppData>(context, listen: false).tripHistoryDataList.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      )
    );
  }
}