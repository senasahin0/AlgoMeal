import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isValidEmail(String email) {
    return RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void register() {

    if (nameController.text.trim().isEmpty) {
      showMessage("Ad Soyad boş bırakılamaz");
      return;
    }

    if (emailController.text.trim().isEmpty) {
      showMessage("E-posta boş bırakılamaz");
      return;
    }

    if (!isValidEmail(emailController.text.trim())) {
      showMessage("Geçerli bir e-posta adresi giriniz");
      return;
    }

    if (passwordController.text.isEmpty) {
      showMessage("Şifre boş bırakılamaz");
      return;
    }

    if (passwordController.text.length < 6) {
      showMessage("Şifre en az 6 karakter olmalıdır");
      return;
    }

    if (confirmPasswordController.text.isEmpty) {
      showMessage("Şifre tekrar alanı boş bırakılamaz");
      return;
    }

    if (passwordController.text !=
        confirmPasswordController.text) {
      showMessage("Şifreler eşleşmiyor");
      return;
    }

    showMessage("Kayıt başarılı");
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kayıt Ol"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [

            const SizedBox(height: 20),

            const Icon(
              Icons.person_add,
              size: 100,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Ad Soyad",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "E-posta",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Şifre",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Şifre Tekrar",
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
                onPressed: register,

                child: const Text(
                  "Kayıt Ol",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}