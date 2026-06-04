import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/user_profile_service.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor';
      case 'invalid-email':
        return 'Geçerli bir e-posta adresi giriniz';
      case 'weak-password':
        return 'Şifre daha güçlü olmalıdır';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin';
      default:
        return 'Kayıt olurken bir hata oluştu';
    }
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty) {
      showMessage('Ad Soyad boş bırakılamaz');
      return;
    }

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

    if (password.length < 6) {
      showMessage('Şifre en az 6 karakter olmalıdır');
      return;
    }

    if (confirmPassword.isEmpty) {
      showMessage('Şifre tekrar alanı boş bırakılamaz');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Şifreler eşleşmiyor');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await UserProfileService().ensureUserDocument(user, name: name);
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
      appBar: AppBar(title: const Text('Kayıt Ol'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.person_add, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Ad Soyad',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'E-posta',
                prefixIcon: const Icon(Icons.mail_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: !showPassword,
              textInputAction: TextInputAction.next,
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
                    showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmPasswordController,
              obscureText: !showConfirmPassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => isLoading ? null : register(),
              decoration: InputDecoration(
                labelText: 'Şifre Tekrar',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  },
                  icon: Icon(
                    showConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : register,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kayıt Ol', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
