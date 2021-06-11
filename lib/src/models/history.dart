import 'package:firebase_database/firebase_database.dart';

class History
{
  String paymentMethod;
  String createdAt;
  String status;
  String fares;
  String dropOff;
  String pickUp;

  History({
    this.createdAt,
    this.dropOff,
    this.fares,
    this.paymentMethod,
    this.pickUp,
    this.status,
    });

    History.fromSnapshot(DataSnapshot snapshot)
    {
      paymentMethod = snapshot.value['payment_method'];
      createdAt = snapshot.value['created_at'];
      status = snapshot.value['status'];
      fares = snapshot.value['fares'];
      dropOff = snapshot.value['dropoff_address'];
      pickUp = snapshot.value['pickup_address'];
    }
   }