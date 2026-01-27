import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, Object error) {
    String message = "An unexpected error occurred";

    if (error is DioException) {
      if (error.response?.data is Map<String, dynamic>) {
        final data = error.response?.data as Map<String, dynamic>;
        if (data.containsKey('detail')) {
          message = data['detail'].toString();
        } else if (data.containsKey('message')) {
          message = data['message'].toString();
        }
      }
    } else {
      message = error.toString();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
