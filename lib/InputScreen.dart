import 'package:bunny_cdn/zongapp.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:bogo_sdk/bogo_sdk.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Simulated API call method
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final token = await login(
        baseUrlV2: 'https://staging2.rtapi.bogo.pk/api-v2',
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ZongApp(
            token: token,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // const Text(
                  //   'Welcome Back',
                  //   style: TextStyle(
                  //     fontSize: 28,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  const SizedBox(height: 32),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      // if (value.length < 6) {
                      //   return 'Password must be at least 6 characters';
                      // }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Button with Loader
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String> login({
    required String baseUrlV2,
    required String email,
    required String password,
  }) async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
    ));

    try {
      final response = await dio.post(
        '$baseUrlV2/api/auth/login',
        data: {
          'email': email,
          'password': password,
          'medium': 'platform-android',
          // 'deviceId': '<any-string>', // add only if the API rejects requests without it
        },
      );

      final jwt = response.data?['data']?['tokens']?['jwtToken'];
      if (jwt is! String || jwt.isEmpty) {
        throw Exception('JWT token not found in login response');
      }
      return jwt;
    } on DioException catch (e) {
      // Surface the API's "msg" if it sent one
      final apiMsg = e.response?.data is Map ? e.response?.data['msg'] : null;
      throw Exception(apiMsg ?? e.message ?? 'Login failed');
    }
  }
  // Future<String?> login({
  //   required String baseUrlV2,
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     final dio = Dio();
  //
  //     final response = await dio.post(
  //       '$baseUrlV2/api/auth/login',
  //       data: {
  //         'email': email,
  //         'password': password,
  //         'medium': 'platform-android'
  //       },
  //     );
  //
  //     final data = response.data;
  //
  //     final jwtToken = data['data']?['tokens']?['jwtToken'];
  //
  //     if (jwtToken == null || jwtToken is! String) {
  //       throw Exception('JWT token not found in login response');
  //     }
  //
  //     return jwtToken;
  //   } on DioException catch (e) {
  //     print('Login API error: ${e.response?.data ?? e.message}');
  //     rethrow;
  //   } catch (e) {
  //     print('Login error: $e');
  //     rethrow;
  //   }
  // }
}