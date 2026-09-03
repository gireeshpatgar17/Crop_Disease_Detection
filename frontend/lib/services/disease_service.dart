import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/disease_result.dart';
import 'api_service.dart';

class DiseaseService {
  /// Sends the selected leaf image to the FastAPI backend for prediction and Supabase storage.
  static Future<DiseaseResult> predictCropDisease(
    XFile imageFile, {
    int farmId = 1,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/disease/predict?farm_id=$farmId');

    final request = http.MultipartRequest('POST', uri);

    final bytes = await imageFile.readAsBytes();
    final filename = imageFile.name.isNotEmpty ? imageFile.name : 'leaf.jpg';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ),
    );

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await request.send().timeout(
            const Duration(seconds: 25),
          );
    } catch (e) {
      throw Exception(
        'Could not connect to backend server at ${ApiService.baseUrl}.\n'
        'Please verify that the FastAPI backend is running.\n'
        'Details: $e',
      );
    }

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return DiseaseResult.fromJson(data);
    } else {
      String errorMessage = 'Server returned status ${response.statusCode}';
      try {
        final errJson = jsonDecode(response.body);
        if (errJson['detail'] != null) {
          errorMessage = errJson['detail'].toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  /// Fetches saved disease history from Supabase via backend.
  static Future<List<Map<String, dynamic>>> getHistory({
    int farmId = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/disease/history?farm_id=$farmId&limit=$limit');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (_) {}
    return [];
  }
}
