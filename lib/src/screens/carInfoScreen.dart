import 'package:flutter/material.dart';
import 'package:jitney_cabs_driver/main.dart';
import 'package:jitney_cabs_driver/src/helpers/configMaps.dart';
import 'package:jitney_cabs_driver/src/helpers/style.dart';
import 'package:jitney_cabs_driver/src/helpers/toastDisplay.dart';
import 'package:jitney_cabs_driver/src/screens/home.dart';

class CarInfoScreen extends StatelessWidget {
  static const String idScreen = "carInfo";
  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carNumberTextEditingController = TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();
  
  String selectedCarType;
  List<String> carTypesList = ["J!tney", "J!tney-Fam", " J!tney-Lux"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 22.0),
              Image.asset("images/logo3B.png"),
              Padding(
                padding: EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 32.0),
                child: Column(
                  children: [
                    SizedBox(height: 12.0,),
                    Text("Enter the car details", style: TextStyle(fontFamily: "Brand-Bold", fontSize: 24.0),),

                    SizedBox(height: 26.0,),
                    TextField(
                      controller: carModelTextEditingController,
                      decoration: InputDecoration(
                        labelText: "Car Model",
                        hintStyle: TextStyle(color: grey, fontSize: 10.0,),
                      ),
                      style: TextStyle(fontSize: 15.0,),
                    ),

                    SizedBox(height: 10.0,),
                    TextField(
                      controller: carNumberTextEditingController,
                      decoration: InputDecoration(
                        labelText: "Car Number",
                        hintStyle: TextStyle(color: grey, fontSize: 10.0,),
                      ),
                      style: TextStyle(fontSize: 15.0,),
                    ),

                    SizedBox(height: 10.0,),
                    TextField(
                      controller: carColorTextEditingController,
                      decoration: InputDecoration(
                        labelText: "Car Color",
                        hintStyle: TextStyle(color: grey, fontSize: 10.0,),
                      ),
                      style: TextStyle(fontSize: 15.0,),
                    ),

                    SizedBox(height: 26.0,),

                    DropdownButton(
                      iconSize:  40.0,
                      hint: Text("Please choose car category"),
                      value: selectedCarType,
                      onChanged: (newValue)
                      {
                        selectedCarType = newValue;
                        displayToastMessage(selectedCarType, context);
                      },
                      items: carTypesList.map((car) 
                      {
                       return DropdownMenuItem(
                        child: new Text(car),
                        value: car,
                       );
                      }).toList(),
                    ),

                    SizedBox(height: 42.0,),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: ()
                        {
                           if(carModelTextEditingController.text.isEmpty)
                           {
                             displayToastMessage("Please add the car model", context);
                           }
                           else if(carNumberTextEditingController.text.isEmpty)
                           {
                             displayToastMessage("Please add the car number", context);
                           }
                           else if(carColorTextEditingController.text.isEmpty)
                           {
                             displayToastMessage("Please add the car color", context);
                           }
                           else if(selectedCarType == null)
                           {
                             displayToastMessage("Please select car category", context);
                           }
                           else
                           {
                             saveDriverCarInfo(context);
                           }
                        }, 
                        child: Padding(
                          padding: const EdgeInsets.all(17.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("NEXT", style: TextStyle(color: white,fontSize: 20.0,fontWeight: FontWeight.bold),),
                              Icon(Icons.arrow_forward, color: white, size: 26.0,),
                            ],
                          ),
                        ),
                        ),
                    ),

                  ],
                ),
                ),
            ],
          ),
        ),
        ),
    );
  }
  void saveDriverCarInfo(context)
  {
    String userId = currentfirebaseUser.uid;

    Map carInfoMap =
    {
      "car_model": carModelTextEditingController.text,
      "car_number": carNumberTextEditingController.text,
      "car_color": carColorTextEditingController.text,
      "type": selectedCarType,
    };

    driversRef.child(userId).child("car_details").set(carInfoMap);
    Navigator.pushNamedAndRemoveUntil(context, HomeScreen.idScreen, (route) => false);
  }

}