import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

class ResponseUtils {
  static Response success(dynamic data, {int statusCode = 200}) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': true,
        'data': data,
      },
    );
  }

  static Response created(dynamic data) {
    return success(data, statusCode: 201);
  }

  static Response error(String message, {int statusCode = 400}) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': false,
        'error': message,
      },
    );
  }

  static Response unauthorized([String message = 'Unauthorized']) {
    return error(message, statusCode: 401);
  }

  static Response forbidden([String message = 'Forbidden']) {
    return error(message, statusCode: 403);
  }

  static Response notFound([String message = 'Not found']) {
    return error(message, statusCode: 404);
  }

  static Response serverError([String message = 'Internal server error']) {
    return error(message, statusCode: 500);
  }

  static Response paginated({
    required List<dynamic> items,
    required int total,
    required int page,
    required int pageSize,
  }) {
    final totalPages = (total / pageSize).ceil();
    return success({
      'items': items,
      'total': total,
      'page': page,
      'pageSize': pageSize,
      'totalPages': totalPages,
      'hasMore': page < totalPages,
    });
  }
}
