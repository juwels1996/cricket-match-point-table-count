import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/event_model.dart';

class EventService {
  final String apiUrl = 'http://192.168.68.101:8000/api/events/';

  Future<List<Event>> fetchEventData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => Event.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load events. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching events: $e');
      throw Exception('Error fetching event data');
    }
  }
}
