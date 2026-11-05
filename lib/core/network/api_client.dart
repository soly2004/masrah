import 'package:flutter/services.dart' show rootBundle;

/// Singleton: the whole app shares one API client.
/// Here it "calls the backend" by reading the bundled JSON after a short delay.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal();

  final Duration latency = const Duration(seconds: 1);

  Future<String> get(String path) async {
    await Future.delayed(latency);
    return rootBundle.loadString(path);
  }
}
