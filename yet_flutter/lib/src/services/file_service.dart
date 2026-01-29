import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class FileService {
  final Dio _dio;
  final String? baseUrl;

  FileService(this._dio, {this.baseUrl});

  Future<String> uploadFile(XFile file) async {
    try {
      String fileName = file.name;

      // On web we must use bytes, on mobile/desktop we can use path but bytes is universal for XFile
      final bytes = await file.readAsBytes();

      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(bytes, filename: fileName),
      });

      // Endpoint: /files/upload
      // It returns {"url": "/static/uploads/..."}
      final response = await _dio.post(
        '/files/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('url')) {
          String url = data['url'];

          // If url starts with http, return as is.
          if (url.startsWith('http')) return url;

          // Resolve relative URL using current Dio base URL
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
      throw e;
    }
  }
}
