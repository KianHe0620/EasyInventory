import 'package:easyinventory/widgets/TextForm.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child:SafeArea(
          child:Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //Title
                Text('Login',
                style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold)),
                SizedBox(height: 30),

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
                //Forgot Passwork
                Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(onPressed: (){
                      //ForgotPasswordLink
                      }, 
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.blue),
                      )
                    ),
                  ),
                  
                ],
            ),
          )
        )
      )
    );
  }
}