import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = "96af71d2a9ae7f61ec230c09fb8ac333";
  static const String _baseUrl = "http://api.weatherstack.com/current";

  static Future<Map<String, dynamic>> fetchWeather(String city) async {
    final url = "$_baseUrl?access_key=$_apiKey&query=$city";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Check for errors in the response
      if (data.containsKey('success') && data['success'] == false) {
        throw Exception(data['error']['info']);
      }

      return data;
    } else {
      throw Exception("Failed to load weather data");
    }
  }
}
