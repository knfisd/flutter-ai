// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'utils/validators.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  bool _isPasswordReset = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool success = false;
    if (_isPasswordReset) {
      success = await authProvider.sendPasswordResetEmail(email);
      if (mounted) {
        if (success) {
          _showSnackBar('Password reset email sent. Please check your inbox.');
          setState(() => _isPasswordReset = false);
        } else {
          _showErrorSnackBar(
            authProvider.error ?? 'Failed to send reset email',
          );
        }
      }
      return;
    }

    if (_isLogin) {
      success = await authProvider.signInWithEmail(email, password);
    } else {
      success = await authProvider.signUpWithEmail(email, password);
    }

    if (mounted) {
      if (success) {
        if (context.mounted) {
          context.go('/recipes');
        }
      } else {
        _showErrorSnackBar(authProvider.error ?? 'Authentication failed');
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (mounted) {
      if (success) {
        if (context.mounted) {
          context.go('/recipes');
        }
      } else {
        _showErrorSnackBar(authProvider.error ?? 'Google sign in failed');
      }
    }
  }

  Future<void> _signInWithFacebook() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithFacebook();

    if (mounted) {
      if (success) {
        if (context.mounted) {
          context.go('/recipes');
        }
      } else {
        _showErrorSnackBar(authProvider.error ?? 'Facebook sign in failed');
      }
    }
  }

  void _continueAsGuest() {
    context.go('/recipes');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isProcessing = authProvider.isLoading;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to\nRecipe App',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isProcessing,
                      validator: Validators.validateEmail,
                    ),

                    if (!_isPasswordReset) ...[
                      const SizedBox(height: 16),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed:
                                () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        enabled: !isProcessing,
                        validator: Validators.validatePassword,
                      ),

                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                                  () => setState(
                                    () =>
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword,
                                  ),
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          enabled: !isProcessing,
                          validator:
                              (value) => Validators.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 24),

                    // Main Action Button
                    ElevatedButton(
                      onPressed: isProcessing ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          isProcessing
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                _isPasswordReset
                                    ? 'Send Reset Email'
                                    : _isLogin
                                    ? 'Login'
                                    : 'Sign Up',
                              ),
                    ),

                    // Toggle between Login/Signup and Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed:
                              isProcessing
                                  ? null
                                  : () => setState(() {
                                    _isPasswordReset = false;
                                    _isLogin = !_isLogin;
                                  }),
                          child: Text(
                            _isLogin
                                ? 'Need an account? Sign up'
                                : 'Already have an account? Login',
                          ),
                        ),
                        if (_isLogin)
                          TextButton(
                            onPressed:
                                isProcessing
                                    ? null
                                    : () => setState(
                                      () =>
                                          _isPasswordReset = !_isPasswordReset,
                                    ),
                            child: Text(
                              _isPasswordReset
                                  ? 'Back to Login'
                                  : 'Forgot Password?',
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Social Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isProcessing ? null : _signInWithGoogle,
                            icon: const Icon(
                              Icons.account_circle,
                              color: Colors.blue,
                            ),
                            // icon: Image.asset(
                            //   'assets/images/google_logo.png',
                            //   height: 24,
                            // ),
                            label: const Text('Google'),
                          ),
                        ),
                        // const SizedBox(width: 16),
                        // Expanded(
                        //   child: OutlinedButton.icon(
                        //     onPressed: isProcessing ? null : _signInWithFacebook,
                        //     icon: const Icon(Icons.facebook, color: Colors.blue),
                        //     label: const Text('Facebook'),
                        //   ),
                        // ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: isProcessing ? null : _continueAsGuest,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Continue as Guest'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
