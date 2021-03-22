class PlacePredictions
{
  String secondary_text;
  String name_text;
  String place_id;

  PlacePredictions({this.secondary_text, this.name_text, this.place_id});

  PlacePredictions.fromJson(Map<String, dynamic> json)
  {
    place_id = json["place_id"];
    secondary_text = json["structured_formatting"]["secondary_text"];
    name_text = json["structured_formatting"]["name_text"];
  }

}