import 'package:easyinventory/controllers/authentication.controller.dart';
import 'package:easyinventory/views/authentication/register.dart';
import 'package:easyinventory/views/mainScreen.dart';
import 'package:easyinventory/views/widgets/button.global.dart';
import 'package:easyinventory/views/widgets/text_form.global.dart';
import 'package:flutter/material.dart';

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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final pass = passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      _showMessage("Please enter email and password");
      return;
    }

    setState(() => _loading = true);
    final err = await _authController.signIn(email, pass);
    setState(() => _loading = false);

    if (err == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      _showMessage(err);
    }
  }

  // ✅ REAL, PRODUCTION forgot password
  Future<void> _forgotPassword() async {
    final TextEditingController resetEmailController =
        TextEditingController(text: emailController.text);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) {
                _showMessage('Please enter your email.');
                return;
              }

              Navigator.pop(context);
              setState(() => _loading = true);

              final err =
                  await _authController.sendPasswordReset(email);

              setState(() => _loading = false);

              if (err == null) {
                _showMessage(
                  'Password reset email sent. Check your inbox.',
                );
              } else {
                _showMessage(err);
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
                  final err =
                      await _authController.signInWithGoogle();
                  setState(() => _loading = false);

                  if (err == null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MainScreen()),
                    );
                  } else {
                    _showMessage(err);
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => RegisterScreen()),
                      );
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
