import 'dart:convert';

import '../../core/network/api_client.dart';
import '../models/event_model.dart';

class LocalDataSource {
  static const String _eventsAsset = 'assets/events_api_response.json';

  final ApiClient _client;

  LocalDataSource(this._client);

  Future<List<EventModel>> fetchEvents() async {
    final raw = await _client.get(_eventsAsset);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    if (decoded['status'] != 'success') {
      throw Exception('Failed to load events');
    }
    return (decoded['data'] as List<dynamic>)
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
