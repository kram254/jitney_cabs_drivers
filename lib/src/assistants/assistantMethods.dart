import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jitney_cabs_driver/src/assistants/requestAssistant.dart';
import 'package:jitney_cabs_driver/src/helpers/configMaps.dart';
import 'package:jitney_cabs_driver/src/models/address.dart';
import 'package:jitney_cabs_driver/src/models/directionDetails.dart';
import 'package:jitney_cabs_driver/src/models/users.dart';
import 'package:jitney_cabs_driver/src/providers/appData.dart';
import 'package:provider/provider.dart';

class AssistantMethods
{
  // static Future<String> searchCoordinateAddress(Position position, context) async
  // {
  //   String placeAddress = "";
  //   String st1, st2, st3, st4;
  //   String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

  //   var response  = await RequestAssistant.getRequest(url);

  //   if(response != "failed")
  //   {
  //     //placeAddress = response["results"][0]["formatted_address"];
  //     st1 = response["results"][0]["address_components"][3]["long_name"];
  //     st2 = response["results"][0]["address_components"][4]["long_name"];
  //     st3 = response["results"][0]["address_components"][5]["long_name"];
  //     st4 = response["results"][0]["address_components"][6]["long_name"];

  //     placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4;

  //     Address userPickUpAddress = new Address();
  //     userPickUpAddress.longitude = position.longitude;
  //     userPickUpAddress.latitude = position.latitude;
  //     userPickUpAddress.placeName = placeAddress;

  //     Provider.of<AppData>(context, listen:  false).updatePickUpLocationAddress(userPickUpAddress);
  //   }
  //   return placeAddress;
  // } 

static Future<DirectionDetails> obtainPlaceDirectionDetails (LatLng initialPosition, LatLng finalPosition) async
{
  String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

  var res = await RequestAssistant.getRequest(directionUrl);

  if(res == "failed")
  {
    return null;
  }

  DirectionDetails directionDetails = DirectionDetails();

  directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];

  directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
  directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];

  directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
  directionDetails.durationValue= res["routes"][0]["legs"][0]["duration"]["value"];

  return directionDetails;

}

static int calculateFares(DirectionDetails directionDetails)
{
  //USD for now
  double timeTraveledFare = (directionDetails.durationValue / 60) * 0.20;
  double distanceTraveledFare = (directionDetails.distanceValue / 1000) * 0.20;
  double totalFareAmount = timeTraveledFare + distanceTraveledFare;

  // converting the totalamount to KSHs

  double totalLocalAmount = totalFareAmount * 109;

  return totalLocalAmount.truncate();
}

// saving the users details into the firebase database
// static void getCurrentOnlineUserInfo() async
// {
//   firebaseUser = await FirebaseAuth.instance.currentUser;
//   String userId = firebaseUser.uid;
//   DatabaseReference reference = FirebaseDatabase.instance.reference().child("users").child(userId);

//   reference.once().then((DataSnapshot dataSnapshot)
//   {
//     if(dataSnapshot.value != null)
//     {
//       userCurrentInfo = Users.fromSnapshot(dataSnapshot);
//     }
//   }
//    );
// }

}