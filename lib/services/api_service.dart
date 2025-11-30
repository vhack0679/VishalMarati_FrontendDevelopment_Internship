import 'dart:convert';
import 'package:flutter/foundation.dart'; // For compute
import 'package:http/http.dart' as http;
import '../models/restful_object.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  final String baseUrl = 'https://api.restful-api.dev/objects';
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  // Top-level function for compute
  static List<RestfulObject> _parseObjects(String responseBody) {
    final List<dynamic> body = jsonDecode(responseBody);
    return body.map((e) => RestfulObject.fromJson(e)).toList();
  }

  // GET List
  Future<List<RestfulObject>> getObjects() async {
    try {
      final response = await client.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        // Use compute to parse in background isolate
        return await compute(_parseObjects, response.body);
      } else {
        throw ApiException('Failed to load objects', statusCode: response.statusCode);
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // GET Detail
  Future<RestfulObject> getObject(String id) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        // The API returns a list with one object for single ID query sometimes, 
        // or the object itself depending on endpoint. 
        // Based on https://restful-api.dev/ documentation:
        // GET https://api.restful-api.dev/objects/7 returns the object directly.
        // But let's handle potential list return just in case based on common quirks, 
        // though spec says object.
        final dynamic body = jsonDecode(response.body);
        if (body is List) {
           if (body.isNotEmpty) return RestfulObject.fromJson(body.first);
           throw ApiException('Object not found');
        }
        return RestfulObject.fromJson(body);
      } else {
        throw ApiException('Failed to load object details', statusCode: response.statusCode);
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // POST Create
  Future<RestfulObject> createObject(String name, Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'data': data,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RestfulObject.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('Failed to create object', statusCode: response.statusCode);
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // PUT Update
  Future<RestfulObject> updateObject(String id, String name, Map<String, dynamic> data) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'data': data,
        }),
      );

      if (response.statusCode == 200) {
        return RestfulObject.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('Failed to update object', statusCode: response.statusCode);
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // DELETE
  Future<void> deleteObject(String id) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200 || response.statusCode == 404) {
        // 404 is considered success for delete (idempotency)
        return;
      } else {
        throw ApiException('Failed to delete object', statusCode: response.statusCode);
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
}
