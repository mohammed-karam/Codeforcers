import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

abstract class Failure {
  final String errorMessage;

  Failure({required this.errorMessage});
}

class ServerFailure extends Failure {
  ServerFailure({required super.errorMessage});

  factory ServerFailure.fromException(Exception exception) {
    if (exception is SocketException) {
      return ServerFailure(
        errorMessage: "No internet connection",
      );
    } else if (exception is TimeoutException) {
      return ServerFailure(errorMessage: "Connection timed out");
    } else if (exception is FormatException) {
      return ServerFailure(errorMessage: "Bad response format from server");
    } else if (exception is HttpException) {
      return ServerFailure(errorMessage: "Couldn't connect to the server");
    } else if (exception is http.ClientException) {
                  return ServerFailure(
        errorMessage: "Can't reach Codeforces — check your connection",
      );
    } else {
      return ServerFailure(errorMessage: "Unexpected error, please try again");
    }
  }

  factory ServerFailure.fromResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 422) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        return ServerFailure(
          errorMessage: decoded['errors'] != null
              ? decoded['errors'][0]?.toString() ?? 'Unknown error'
              : _messageFromErrorObject(decoded) ??
                  decoded['message']?.toString() ??
                  decoded['Message']?.toString() ??
                  decoded['detail']?.toString() ??
                  'Request failed with status $statusCode',
        );
      } catch (_) {
        return ServerFailure(
          errorMessage: 'Request failed with status $statusCode',
        );
      }
    } else if (statusCode == 404) {
      return ServerFailure(
        errorMessage: 'Your request was not found, please try later!',
      );
    } else if (statusCode == 500) {
      return ServerFailure(
        errorMessage: 'Internal server error, please try later!',
      );
    } else {
      try {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        return ServerFailure(
          errorMessage: decoded['errors'] != null
              ? decoded['errors'][0]?.toString() ?? 'Unknown error'
              : _messageFromErrorObject(decoded) ??
                  decoded['message']?.toString() ??
                  decoded['detail']?.toString() ??
                  'Request failed with status $statusCode',
        );
      } catch (_) {
        return ServerFailure(
          errorMessage: 'Request failed with status $statusCode',
        );
      }

    }
  }
}

String? _messageFromErrorObject(Map<String, dynamic> decoded) {
  final error = decoded['error'];
  if (error is Map && error['message'] != null) {
    return error['message'].toString();
  }
  return null;
}

class MissingApiKeyFailure extends Failure {
  MissingApiKeyFailure()
      : super(
          errorMessage:
              'Add your own Groq API key to use the AI Answer Checker.',
        );
}
