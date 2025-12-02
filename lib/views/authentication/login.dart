// lib/views/authentication/login.dart
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
      // Success — replace with MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      _showMessage(err);
    }
  }

  Future<void> _forgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showMessage("Enter your email to reset password.");
      return;
    }

    setState(() => _loading = true);
    final err = await _authController.sendPasswordReset(email);
    setState(() => _loading = false);

    if (err == null) {
      _showMessage("Password reset email sent. Check your inbox.");
    } else {
      _showMessage(err);
    }
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
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text('Login',
                    style:
                        TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Column(
                  children: [
                    //Email Input
                    TextForm(
                      controller: emailController,
                      text: 'Email Address',
                      textInputType: TextInputType.emailAddress,
                      obscure: false,
                    ),
                    const SizedBox(height: 15),

                    //Password Input
                    TextForm(
                      controller: passwordController,
                      text: 'Password',
                      textInputType: TextInputType.text,
                      obscure: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                //Forgot Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                      onPressed: _forgotPassword,
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: const Color(0xFF0A84D0)),
                      )),
                ),
                const SizedBox(height: 8),

                //Login Button
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ButtonGlobal(
                        boxColor: const Color(0xFF0A84D0),
                        text: 'Log In',
                        textColor: Colors.white,
                        width: 0,
                        onTap: _login,
                      ),

                //Divider Line
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: Colors.grey, thickness: 0.8)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Or',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                              color: Colors.grey, thickness: 0.8))
                    ],
                  ),
                ),

                //Google Login Button (placeholder)
                ButtonGlobal(
                  boxColor: Colors.white,
                  text: 'Login with Google',
                  textColor: Colors.black,
                  width: 1,
                  onTap: () async {
                    setState(() => _loading = true);
                    final err = await _authController.signInWithGoogle();
                    setState(() => _loading = false);

                    if (err == null) {
                      // success -> go to main screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                    }
                  },
                ),
                const SizedBox(height: 30),

                //Register Text Button
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Register a new account?'),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()),
                            );
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: const Color(0xFF0A84D0),
                              fontSize: 18,
                            ),
                          )),
                    ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
