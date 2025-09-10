import 'package:easyinventory/views/authentication/register.dart';
import 'package:easyinventory/views/mainScreen.dart';
import 'package:easyinventory/views/utils/global.colors.dart';
import 'package:easyinventory/views/widgets/button.global.dart';
import 'package:easyinventory/views/widgets/text_form.global.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:SingleChildScrollView(
          child:Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                //Forgot Password
                Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(onPressed: (){
                      //ForgotPasswordLink
                      }, 
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color:GlobalColors.mainColor),
                      )
                    ),
                  ),
                const SizedBox(height: 8),

                //Login Button
                ButtonGlobal(
                  boxColor: GlobalColors.mainColor, 
                  text: 'Log In', 
                  textColor: Colors.white, 
                  width: 0,
                  onTap: () {
                    //Login Success
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (_) => const MainScreen()) 
                    );
                  },),

                //Divider Line
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey,thickness: 0.8,)),
                      const Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 8.0),
                        child: Text(
                          'Or',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey,thickness: 0.8,))
                    ],
                  ),
                ),

                //Google Login Button
                ButtonGlobal(
                  boxColor: Colors.white, 
                  text: 'Login with Google', 
                  textColor: Colors.black, 
                  width: 1,
                  onTap: () {
                    
                  },),
                SizedBox(height: 30,),

                //Register Text Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    Text('Register a new account?'),
                    TextButton(onPressed: (){
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context)=> RegisterScreen()
                        )
                      );
                    }, 
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: GlobalColors.mainColor,
                        fontSize: 18,
                        )
                      )
                    ),
                  ]
                )
              ],
            ),
          )
        )
      )
    );
  }
}