import 'package:firebase_database/firebase_database.dart';

class Drivers
{
  String name;
  String phone;
  String email;
  String id;
  String car_color;
  String car_model;
  String car_number;

  Drivers({this.name,this.car_color,this.car_model, this.car_number, this.email, this.id, this.phone});

  Drivers.fromSnapshot(DataSnapshot dataSnapShot)
  {
    id = dataSnapShot.key;
    name = dataSnapShot.value["name"];
    phone = dataSnapShot.value["phone"];
    email = dataSnapShot.value["email"];
    car_color = dataSnapShot.value["car_details"]["car_color"];
    car_model= dataSnapShot.value["car_details"]["car_model"];
    car_number= dataSnapShot.value["car_details"]["car_number"];

  }
}