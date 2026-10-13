import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/features/submit/data/cf_submission.dart';
import 'package:http/http.dart' as http;

class CfSubmissionsApi {
  CfSubmissionsApi({http.Client? client}) : _client = client ?? http.Client();

    static const String _userAgent =
      'fawateery/1.0 (+https://codeforces.com); submission tracker';

  final http.Client _client;

            Future<Either<Failure, CfSubmission?>> latestFor(String handle) async {
    final trimmed = handle.trim();
    if (trimmed.isEmpty) {
      return Left(
        ServerFailure(errorMessage: 'Add your Codeforces handle to watch it.'),
      );
    }

    try {
      final response = await _client.get(
        Uri.https('codeforces.com', '/api/user.status', <String, String>{
          'handle': trimmed,
          'from': '1',
          'count': '1',
        }),
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode != 200) {
        return Left(ServerFailure.fromResponse(response));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return Left(ServerFailure(errorMessage: 'Unexpected answer from Codeforces.'));
      }
      if (decoded['status'] != 'OK') {
        return Left(
          ServerFailure(
            errorMessage: (decoded['comment'] ?? 'Codeforces rejected the request.')
                .toString(),
          ),
        );
      }

      final result = decoded['result'];
      if (result is! List || result.isEmpty) return const Right(null);

      final newest = result.first;
      if (newest is! Map<String, dynamic>) return const Right(null);

      return Right(CfSubmission.fromApiJson(newest));
    } on Exception catch (error) {
      return Left(ServerFailure.fromException(error));
    }
  }
}
