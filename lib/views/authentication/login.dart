import 'package:easyinventory/controllers/authentication.controller.dart';
import 'package:easyinventory/views/authentication/register.dart';
import 'package:easyinventory/views/main_screen.dart';
import 'package:easyinventory/views/widgets/button.global.dart';
import 'package:easyinventory/views/widgets/text_form.global.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthController _authController = AuthController();

  bool _loading = false;

  void _showMessage(String msg) {
    Get.snackbar('Message', msg);
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final pass = passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      _showMessage("Please enter email and password");
      return;
    }

    setState(() => _loading = true);
    final error = await _authController.signIn(email, pass);

    if (!mounted) return;

    setState(() => _loading = false);

    if (error == null) {
      Get.off(() => const MainScreen());
    } else {
      _showMessage(error);
    }
  }

  // ✅ REAL, PRODUCTION forgot password
  Future<void> _forgotPassword() async {
    final TextEditingController resetEmailController =
        TextEditingController(text: emailController.text);

    Get.dialog(
      AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: resetEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) {
                _showMessage('Please enter your email.');
                return;
              }

              Get.back();
              setState(() => _loading = true);

              final error = await _authController.sendPasswordReset(email);

              setState(() => _loading = false);

              if (error == null) {_showMessage('Password reset email sent. Check your inbox.',);
              } else {
                _showMessage(error);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Login',
                style:
                    TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              TextForm(
                controller: emailController,
                text: 'Email Address',
                textInputType: TextInputType.emailAddress,
                obscure: false,
              ),
              const SizedBox(height: 15),

              TextForm(
                controller: passwordController,
                text: 'Password',
                textInputType: TextInputType.text,
                obscure: true,
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Color(0xFF0A84D0)),
                  ),
                ),
              ),

              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ButtonGlobal(
                      boxColor: const Color(0xFF0A84D0),
                      text: 'Log In',
                      textColor: Colors.white,
                      width: 0,
                      onTap: _login,
                    ),

              const SizedBox(height: 20),

              ButtonGlobal(
                boxColor: Colors.white,
                text: 'Login with Google',
                textColor: Colors.black,
                width: 1,
                onTap: () async {
                  setState(() => _loading = true);
                  final error = await _authController.signInWithGoogle();
                  if(!mounted) return;
                  setState(() => _loading = false);

                  if (error == null) {
                    Get.offAll(()=> const MainScreen());
                  } else {
                    _showMessage(error);
                  }
                },
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Register a new account?'),
                  TextButton(
                    onPressed: () {
                      Get.to(()=>RegisterScreen());
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Color(0xFF0A84D0),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
