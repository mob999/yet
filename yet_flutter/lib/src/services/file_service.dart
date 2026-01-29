import 'dart:io';
import 'package:dio/dio.dart';

class FileService {
  final Dio _dio;
  final String? baseUrl;

  FileService(this._dio, {this.baseUrl});

  Future<String> uploadFile(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      // The generated client had issues with return type, so we use dio directly.
      // Endpoint: /files/upload
      // It returns {"url": "/static/uploads/..."}
      final response = await _dio.post(
        '/files/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('url')) {
          // If we have a base URL, and the returned URL is relative (starts with /),
          // we might want to prepend it.
          // However, for storage, it's often better to store the relative path or full URL.
          // Let's rely on the backend returning a usable path.
          // If backend returns relative path, we prepend base URL for display,
          // but for database storage, relative path is fine if we always resolve it.
          // Actually, let's just return what the backend gave.
          // Wait, backend returns `/static/uploads/uuid.jpg`.
          // We need the full URL for Image.network to work if headers aren't set up perfectly or for simple usage.

          String url = data['url'];

          // If url starts with http, return as is.
          if (url.startsWith('http')) return url;

          // If relative, and we have a baseUrl, preload it?
          // Actually, let's just return the relative path (or whatever fits logic).
          // For Image.network, we need absolute URL.
          // Let's resolve it here if possible.
          if (baseUrl != null && url.startsWith('/')) {
            // Remove trailing slash from base if present
            final base = baseUrl!.endsWith('/')
                ? baseUrl!.substring(0, baseUrl!.length - 1)
                : baseUrl!;
            return '$base$url';
          }
          // Fallback to what we got (it might work if relative paths are supported by some magical widgets, but usually not)
          // Actually, the ConfigService knows the current base URL.
          // But Dio instance has a baseUrl too.
          final dioBase = _dio.options.baseUrl;
          if (dioBase.isNotEmpty && url.startsWith('/')) {
            final base = dioBase.endsWith('/')
                ? dioBase.substring(0, dioBase.length - 1)
                : dioBase;
            return '$base$url';
          }

          return url;
        }
      }
      throw Exception('Upload failed: Invalid response format');
    } catch (e) {
      // Re-throw or handle?
      // Let caller handle UI feedback.
      throw e;
    }
  }
}
