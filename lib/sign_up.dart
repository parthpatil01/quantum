import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quantum_it/main.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';


class SignUp extends StatefulWidget {

  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {



  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var error='';
  var visible=false;
  var visible_error=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Sign Up')),
      body: SingleChildScrollView(child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Quantum It',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 30),
                  )),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 20),
                  )),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'User Name',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),

              Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: visible_error,
                  child: Container(
                      margin: EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(error,style: TextStyle(color: Colors.red,fontSize: 12),)
                  )
              ),

              Container(
                  height: 50,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    child: const Text('Sign Up'),
                    onPressed: () async {

                      if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                        setState(() {
                          visible = true;
                        });
                        try {
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            SystemNavigator.pop();
                          }
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            setError('The password provided is too weak.');
                          } else if (e.code == 'email-already-in-use') {
                            setError('The account already exists for that email.');
                          }
                          setState(() {
                            visible = false;
                          });
                        } catch (e) {
                          setError(e.toString());
                          setState(() {
                            visible = false;
                          });
                        }
                      }else{
                        setError('Fields cannot be empty');
                      }


                    },
                  )
              ),


              Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: visible,
                  child: Container(
                      margin: EdgeInsets.only(top: 50, bottom: 30),
                      child: CircularProgressIndicator()
                  )
              ),


            ],
          )),),);



  }

  setError(String e){
    setState(() {
      error=e;
      visible_error=true;
    });
  }

}
