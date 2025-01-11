import 'dart:convert';
import 'package:http/http.dart' as http;

class EquifaxAPI {
  final String _baseUrl = 'https://api.equifax.com';  // Adjust based on API documentation
  final String _apiKey = '<YOUR_API_KEY>';  // Replace with your actual API key

  // Function to get credit score (example)
  Future<Map<String, dynamic>> getCreditScore(String ssn, String name, String dob, String address) async {
    final Uri url = Uri.parse('$_baseUrl/credit-score');

    // Prepare request payload
    Map<String, String> body = {
      'consumer_ssn': ssn,
      'consumer_name': name,
      'consumer_dob': dob,
      'consumer_address': address,
    };

    // Set up headers with Authorization (Bearer token, or API Key)
    Map<String, String> headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Parse the response
        return json.decode(response.body);
      } else {
        // Handle API error (e.g., wrong API key, invalid data)
        throw Exception('Failed to fetch credit score: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch credit score: $e');
    }
  }

  // Function to get credit report (another example)
  Future<Map<String, dynamic>> getCreditReport(String ssn, String name, String dob, String address) async {
    final Uri url = Uri.parse('$_baseUrl/credit-report');

    // Prepare request payload
    Map<String, String> body = {
      'consumer_ssn': ssn,
      'consumer_name': name,
      'consumer_dob': dob,
      'consumer_address': address,
    };

    // Set up headers with Authorization (Bearer token, or API Key)
    Map<String, String> headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Parse the response
        return json.decode(response.body);
      } else {
        // Handle API error
        throw Exception('Failed to fetch credit report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch credit report: $e');
    }
  }
}
