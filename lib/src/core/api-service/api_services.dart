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

  Future<Map<String, List<Sponsor>>> fetchSponsors() async {
    final response =
        await http.get(Uri.parse('https://backend.dplt10.org/api/sponsor/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, List<Sponsor>> groupedSponsors = {};

      data.forEach((category, sponsorsJson) {
        final sponsorsList = (sponsorsJson as List)
            .map((item) => Sponsor.fromJson(item))
            .toList();
        groupedSponsors[category] = sponsorsList;
      });

      return groupedSponsors;
    } else {
      throw Exception('Failed to load sponsors');
    }
  }
}
