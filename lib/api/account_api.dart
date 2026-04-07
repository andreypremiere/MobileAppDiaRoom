import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dia_room/configuration/urls.dart';
import 'package:dia_room/models/user.dart';
import 'package:dia_room/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../models/auth_response.dart';
import '../utils/dio_service.dart';

Future<AuthResponse> requestRegistration(String email, String password) async {
  try {
    final response = await ApiService.post(
      '/account/newAccount',
      data: {
        "email": email,
        "password": password,
      },
    );

    return AuthResponse(success: true, data: response.data);

  } on DioException catch (e) {
    String errorMessage = "Произошла ошибка";

    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      errorMessage = "Сервер не отвечает, попробуйте позже";
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = "Нет соединения с интернетом";
    } else if (e.response != null) {
      errorMessage = e.response?.data['error'] ?? "Неизвестная ошибка сервера";
    }

    return AuthResponse(success: false, message: errorMessage);
  } catch (e) {
    return AuthResponse(success: false, message: "Непредвиденная ошибка: $e");
  }
}

Future<AuthResponse> requestVerifyCode(String userId, String code) async {
  try {
    final response = await ApiService.post(
      '/account/verify/$userId',
      data: {'code': code},
    );

    return AuthResponse(success: true, data: response.data);

  } on DioException catch (e) {
    String errorMessage = "Ошибка верификации";

    if (e.response != null) {
      errorMessage = e.response?.data['error'] ?? "Неизвестная ошибка";
    } else {
      errorMessage = "Проблемы с соединением";
    }

    return AuthResponse(success: false, message: errorMessage);
  } catch (e) {
    return AuthResponse(success: false, message: "Ошибка: $e");
  }
}

Future<AuthResponse> requestLogin(String email, String password) async {
  try {

    final response = await ApiService.post(
      '/account/login',
      data: {'email': email,
      'password': password},
    );

    return AuthResponse(
        success: true,
        data: response.data
    );

  } on DioException catch (e) {
    String errorMessage = "Ошибка при поиске пользователя";

    if (e.response != null) {
      errorMessage = e.response?.data['error'] ?? "Пользователь не найден";
    } else {
      errorMessage = "Не удалось связаться с сервером";
    }

    return AuthResponse(success: false, message: errorMessage);
  } catch (e) {
    return AuthResponse(success: false, message: "Непредвиденная ошибка: $e");
  }
}
