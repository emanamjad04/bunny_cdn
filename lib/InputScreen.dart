import 'package:bogo_sdk/bogo_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'local_config.dart';
import 'mock_partner_backend.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final MockPartnerBackend _partnerBackend = MockPartnerBackend();
  late bool _useSdkAuth = LocalConfig.useSdkAuth;
  String? _token;
  bool _isLoading = false;
  String? _lastError;

  Future<String> _login() async {
    if (_useSdkAuth) {
      return _partnerBackend.requestSdkToken();
    }
    final response = await Dio().post(
      '${LocalConfig.loginBaseUrl}/api/auth/login',
      data: {
        'email': LocalConfig.email,
        'password': LocalConfig.password,
        'medium': 'platform-android',
      },
    );
    final token = response.data?['data']?['tokens']?['jwtToken'];
    if (token is! String || token.isEmpty) {
      throw StateError('JWT token not found in login response');
    }
    return token;
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _lastError = null;
    });
    try {
      final token = await _login();
      if (mounted) setState(() => _token = token);
    } on Object {
      if (mounted) setState(() => _lastError = 'Partner login failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openBogo() async {
    final token = _token;
    if (token == null) return;
    await BogoSdk.open(
      context,
      token,
      onTokenRequest: _login,
      onError: (error) {
        if (mounted) {
          setState(() => _lastError = 'BOGO reported an error');
        }
      },
      onClosed: () {
        if (mounted) setState(() => _lastError = null);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bunny CDN partner demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: _isLoading ? null : _signIn,
                child: Text(_isLoading ? 'Signing in...' : 'Partner test login'),
              ),
              SwitchListTile(
                title: const Text('Use new SDK auth flow'),
                value: _useSdkAuth,
                onChanged: (value) => setState(() {
                  _useSdkAuth = value;
                  _token = null;
                  _lastError = null;
                }),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _token == null ? null : _openBogo,
                child: const Text('Open BOGO'),
              ),
              if (_lastError != null) ...[
                const SizedBox(height: 16),
                Text(_lastError!, style: TextStyle(color: Colors.red.shade700)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
