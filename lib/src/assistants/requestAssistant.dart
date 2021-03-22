import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> getRequest(String url) async
  {
    //sending the httpRequest...
    http.Response response = await http.get(url);

 // Handling all the exceptions... errorHandling
    try {
    //decoding the data from the response...
    if(response.statusCode == 200)
    {
      String jsonData = response.body;
      var decodeData = jsonDecode(jsonData);
      return decodeData;
    }
    else
    {
      return "failed";
    }
    } catch (e) 
    {
      return "failed";
    }
  }
}