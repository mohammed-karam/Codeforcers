import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

String _getRandom6Digits() {
  final random = Random();
  final number = 100000 + random.nextInt(900000);   return number.toString();
}

String _sha512(String input) {
  final bytes = utf8.encode(input);
  final digest = sha512.convert(bytes);
  return digest.toString();
}

String generateCodeforcesUrl({
  required String methodName,
  required Map<String, String> params,
  required String apiKey,
  required String apiSecret,
}) {
    final Map<String, String> allParams = Map.from(params);
  allParams['apiKey'] = apiKey;
  
  final unixTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
  allParams['time'] = unixTime;

    final sortedKeys = allParams.keys.toList()..sort();
  final queryString = sortedKeys.map((k) => '$k=${allParams[k]}').join('&');

    final randPrefix = _getRandom6Digits();

    final toHash = '$randPrefix/$methodName?$queryString#$apiSecret';

    final hashHex = _sha512(toHash);
  final apiSig = '$randPrefix$hashHex';

    return 'https://codeforces.com/api/$methodName?$queryString&apiSig=$apiSig';
}
