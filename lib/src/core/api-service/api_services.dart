import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/photo_gallery.dart';

class ApiService {
  final String apiUrl = 'http://192.168.68.103:8000/api/matchgallery/';

  // Fetch match gallery data
  Future<List<MatchGallery>> fetchMatchGallery() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        return jsonData
            .map((jsonItem) => MatchGallery.fromJson(jsonItem))
            .toList();
      } else {
        throw Exception('Failed to load match gallery');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching match gallery');
    }
  }
}
