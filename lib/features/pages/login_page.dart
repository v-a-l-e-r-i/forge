import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../widgets/forge_brand_card.dart';
import '../../widgets/forge_logo.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  Future<void> login() async {
    final nickname = nicknameController.text.trim();
    final password = passwordController.text.trim();

    if (nickname.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill all fields'),
        ),
      );
      return;
    }

    try {
      setState(() => loading = true);

      await context.read<AuthService>().login(
            nickname: nickname,
            password: password,
          );

      if (!mounted) return;
      // AuthWrapper rebuilds to HomePage when auth state changes.
    } on FirebaseAuthException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Invalid nickname or password'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: ${e.toString()}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    nicknameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    InputDecoration buildLoginInputDecoration(String label, IconData icon, IconButton? leftIcon) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: colors.secondary.withValues(alpha: 0.7),
        ),
        prefixIcon: Icon(icon, color: colors.secondary.withValues(alpha: 0.5)),
        suffixIcon: leftIcon,
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colors.primary,
            width: 2,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: 360,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ForgeLogo(size: 72, onTap: () => showForgeBrandCard(context)),
                    const SizedBox(height: 16),
                    Text(
                      'FORGE',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to your workspace',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.secondary.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: nicknameController,
                      keyboardType: TextInputType.text,
                      autofillHints: const [AutofillHints.username],
                      decoration: buildLoginInputDecoration(
                        'Логін',
                        Icons.person,
                        null
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введіть ваш логін';
                        }
                        return null;
                      },
                      enabled: !_isSubmitting,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],

                      decoration: buildLoginInputDecoration(
                        'Пароль',
                        Icons.lock_outline,
                        IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: colors.onInverseSurface,
                          ),
                          onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введіть ваш пароль';
                        }
                        return null;
                      },
                      enabled: !_isSubmitting,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: loading
                            ? CircularProgressIndicator(
                                color: colors.onPrimary,
                                strokeWidth: 2,
                              )
                            : const Text(
                                'ENTER THE FORGE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New to the smithy?',
                          style: TextStyle(
                            color: colors.secondary.withValues(alpha: 0.6),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
