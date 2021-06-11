import 'package:flutter/cupertino.dart';
import 'package:jitney_cabs_driver/src/models/address.dart';
import 'package:jitney_cabs_driver/src/models/history.dart';

class AppData extends ChangeNotifier
{
  String  earnings = "0";
  int countTrips = 0;
  List<String> tripHistoryKeys = [];
  List<History> tripHistoryDataList = [];
  
void updateEarnings(String updateEarnings)
{
  earnings = updateEarnings;
  notifyListeners();
}  

void updateTripsCounter(int tripCounter)
{
  countTrips = tripCounter;
  notifyListeners();
}

void updateTripKeys(List<String> newKeys)
{
  tripHistoryKeys= newKeys;
  notifyListeners();
}

void updateTripHistoryData(History eachHistory)
{
  tripHistoryDataList.add(eachHistory);
  notifyListeners();
}

}