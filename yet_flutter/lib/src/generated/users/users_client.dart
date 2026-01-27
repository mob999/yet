// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/body_login_users_login_post.dart';
import '../models/token.dart';
import '../models/user.dart';
import '../models/user_create.dart';
import '../models/user_profile.dart';
import '../models/user_profile_update.dart';

part 'users_client.g.dart';

@RestApi()
abstract class UsersClient {
  factory UsersClient(Dio dio, {String? baseUrl}) = _UsersClient;

  /// Register
  @POST('/users/register')
  Future<User> registerUsersRegisterPost({
    @Body() required UserCreate body,
  });

  /// Login
  @FormUrlEncoded()
  @POST('/users/login')
  Future<Token> loginUsersLoginPost({
    @Body() required BodyLoginUsersLoginPost body,
  });

  /// Read Users Me
  @GET('/users/me')
  Future<User> readUsersMeUsersMeGet();

  /// Update My Profile
  @PUT('/users/me/profile')
  Future<UserProfile> updateMyProfileUsersMeProfilePut({
    @Body() required UserProfileUpdate body,
  });
}
