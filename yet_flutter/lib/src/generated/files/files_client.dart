// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'files_client.g.dart';

@RestApi()
abstract class FilesClient {
  factory FilesClient(Dio dio, {String? baseUrl}) = _FilesClient;

  /// Upload File.
  ///
  /// Upload a file and return its URL.
  @MultiPart()
  @POST('/files/upload')
  Future<void> uploadFileFilesUploadPost({
    @Part(name: 'file') required File file,
  });
}
