import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/photo_gallery.dart';
import '../model/sponsor_model.dart';

class ApiService {
  final String apiUrl = 'https://backend.dplt10.org/api/matchgallery/';

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

  Future<List<Sponsor>> fetchSponsors() async {
    try {
      final response =
          await http.get(Uri.parse('https://backend.dplt10.org/api/sponsor/'));

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Decode the JSON response body into a list
        final List<dynamic> data = jsonDecode(response.body);

        // Convert the list into a list of Sponsor objects
        final List<Sponsor> sponsors =
            data.map((item) => Sponsor.fromJson(item)).toList();

        return sponsors;
      } else {
        throw Exception(
            'Failed to load sponsors, status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors (e.g., network issues)
      print('Error fetching sponsors: $error');
      throw Exception('Failed to load sponsors');
    }
  }
}
