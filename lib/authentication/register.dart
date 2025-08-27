import 'package:easyinventory/authentication/Login.dart';
import 'package:easyinventory/utils/global.colors.dart';
import 'package:easyinventory/widgets/button.global.dart';
import 'package:easyinventory/widgets/textForm.global.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                //Title
                Text('Register',
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
                    const SizedBox(height: 15),

                    TextForm(
                      controller: passwordController,
                      text: 'Confirm Password',
                      textInputType: TextInputType.text,
                      obscure: true,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                //Login Button
                ButtonGlobal(
                  boxColor: GlobalColors.mainColor, 
                  text: 'Register', 
                  textColor: Colors.white, 
                  width: 0,
                  onTap: () {

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
                    Text('Already own an account?'),
                    TextButton(onPressed: (){
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context)=> LoginScreen()
                        )
                      );
                    }, 
                    child: Text(
                      'Login',
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