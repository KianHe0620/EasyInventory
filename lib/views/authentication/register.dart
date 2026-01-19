import 'package:easyinventory/controllers/authentication.controller.dart';
import 'package:easyinventory/views/authentication/Login.dart';
import 'package:flutter/material.dart';
import 'package:easyinventory/views/widgets/button.global.dart';
import 'package:easyinventory/views/widgets/text_form.global.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final AuthController authController = AuthController();

  bool loading = false;

  void registerUser() async {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showMessage("All fields are required");
      return;
    }

    if (pass != confirm) {
      _showMessage("Passwords do not match");
      return;
    }

    setState(() => loading = true);

    final error = await authController.register(email, pass);

    setState(() => loading = false);

    if (error == null) {
      _showMessage("Registration successful!");
      Get.offAll(()=>LoginScreen());
    } else {
      _showMessage(error);
    }
  }

  void _showMessage(String msg) {
    Get.snackbar('Message', msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Register',
                    style: TextStyle(
                        fontSize: 35, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                // Email
                TextForm(
                  controller: emailController,
                  text: 'Email Address',
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),

                // Password
                TextForm(
                  controller: passwordController,
                  text: 'Password',
                  obscure: true, 
                  textInputType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 15),

                // Confirm
                TextForm(
                  controller: confirmController,
                  text: 'Confirm Password',
                  obscure: true, 
                  textInputType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 30),

                loading
                    ? const Center(child: CircularProgressIndicator())
                    : ButtonGlobal(
                        boxColor: const Color(0xFF0A84D0),
                        text: 'Register',
                        textColor: Colors.white,
                        width: 0,
                        onTap: registerUser,
                      ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {Get.offAll(()=>LoginScreen());},
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: const Color(0xFF0A84D0),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
