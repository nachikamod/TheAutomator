// ignore_for_file: file_names

import 'package:automator/services/authentication_service.dart';
import 'package:automator/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late GlobalKey<FormState> _signIn;
  late String _email;
  late String _password;
  bool _progress = false;

  @override
  void initState() {
    super.initState();

    _signIn = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'aTm',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 50,
              ),
              Form(
                key: _signIn,
                child: Column(
                  children: [
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 0.0),
                        ),
                        hintText: "Email",
                        helperStyle: TextStyle(color: Colors.white24),
                        hintStyle: TextStyle(color: Colors.white24),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email address';
                        }
                        if (!RegExp(
                                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                            .hasMatch(value)) return 'Invalid email';
                        return null;
                      },
                      onSaved: (value) {
                        _email = value!;
                      },
                      maxLength: 30,
                      maxLines: 1,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 0.0),
                        ),
                        hintText: "Password",
                        helperStyle: TextStyle(color: Colors.white24),
                        hintStyle: TextStyle(color: Colors.white24),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        if (!RegExp(
                                r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$")
                            .hasMatch(value)) {
                          return 'Password should have minimum eight characters, at least one uppercase letter, one lowercase letter, one number and one special character';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value!;
                      },
                      maxLength: 30,
                      maxLines: 1,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Visibility(
                      visible: !_progress,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: const Text('Login'),
                          onPressed: () async {
                            setState(() {
                              _progress = true;
                            });
                            if (_signIn.currentState!.validate()) {
                              _signIn.currentState!.save();
                              String result = await context
                                  .read<AuthenticationService>()
                                  .signIn(email: _email, password: _password);
                              if (result == 'Signed in') {
                                setState(() {
                                  _progress = false;
                                });
                              } else {
                                setState(() {
                                  _progress = false;
                                });
                                Fluttertoast.showToast(
                                    msg: result,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.SNACKBAR,
                                    backgroundColor:
                                        Color(CustomColors().Card_dark),
                                    textColor: Colors.white);
                              }
                            } else {
                              setState(() {
                                _progress = false;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _progress,
                      child: const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
}
