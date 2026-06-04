import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/user_profile_service.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Geçerli bir e-posta adresi giriniz';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin';
      default:
        return 'Giriş yapılırken bir hata oluştu';
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      showMessage('E-posta boş bırakılamaz');
      return;
    }

    if (!isValidEmail(email)) {
      showMessage('Geçerli bir e-posta adresi giriniz');
      return;
    }

    if (password.isEmpty) {
      showMessage('Şifre boş bırakılamaz');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await UserProfileService().ensureUserDocument(user);
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        showMessage(authErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    const Text(
                      'AlgoMeal',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Akıllı yemek planlama asistanın',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: const Icon(Icons.mail_outline),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.92),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => isLoading ? null : login(),
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          icon: Icon(
                            showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.92),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isLoading ? null : login,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4CAF50),
                          side: const BorderSide(color: Color(0xFF4CAF50)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                        child: const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomeScreen(),
                                ),
                                (route) => false,
                              );
                            },
                      child: const Text(
                        'Misafir olarak devam et',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
