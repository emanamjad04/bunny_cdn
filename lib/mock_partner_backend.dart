import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:jose/jose.dart';

import 'local_config.dart';

/// Real partners build this request on their own server, never inside an app.
class MockPartnerBackend {
  MockPartnerBackend({Dio? client}) : _client = client ?? Dio();

  final Dio _client;

  Future<String> requestSdkToken() async {
    final bogoPublicKey = JsonWebKey.fromPem(
      await rootBundle.loadString(LocalConfig.sdkBogoPublicKeyAsset),
    );
    final partnerPrivateKey = JsonWebKey.fromPem(
      await rootBundle.loadString(LocalConfig.sdkPartnerPrivateKeyAsset),
    );
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    final jweBuilder = JsonWebEncryptionBuilder()
      ..stringContent = jsonEncode({
        'phone': LocalConfig.sdkPhone,
        'name': LocalConfig.sdkName,
        'email': LocalConfig.sdkEmail,
      })
      ..setProtectedHeader('alg', 'RSA-OAEP-256')
      ..setProtectedHeader('enc', 'A256GCM')
      ..addRecipient(bogoPublicKey, algorithm: 'RSA-OAEP-256');
    final jwe = jweBuilder.build().toCompactSerialization();

    final jwsBuilder = JsonWebSignatureBuilder()
      ..jsonContent = {
        'iss': LocalConfig.sdkEntityKey,
        'aud': LocalConfig.sdkTokenUrl,
        'iat': now,
        'exp': now + 30,
        'jti': _jti(),
        'jwe': jwe,
      }
      ..setProtectedHeader('alg', 'ES256')
      ..setProtectedHeader('kid', LocalConfig.sdkKid)
      ..addRecipient(partnerPrivateKey, algorithm: 'ES256');
    final jws = jwsBuilder.build().toCompactSerialization();

    final response = await _client.post(
      LocalConfig.sdkTokenUrl,
      data: {'jws': jws},
      options: Options(contentType: Headers.jsonContentType),
    );
    final token = response.data?['data']?['token'];
    if (token is! String || token.isEmpty) {
      throw StateError('SDK temporary token not found');
    }
    return token;
  }

  String _jti() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_randomSuffix()}';

  String _randomSuffix() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}
