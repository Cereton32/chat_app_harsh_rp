import 'dart:math';

import 'package:chat_app_harsh_rp/api/api.dart';
import 'package:chat_app_harsh_rp/auth/auth_function.dart';
import 'package:chat_app_harsh_rp/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_app_harsh_rp/utils/progressbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAnimated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      setState(() {
        isAnimated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        final height = MediaQuery.of(context).size.height;
        final width = MediaQuery.of(context).size.width;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Welcome to We Chat",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          body: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  duration: Duration(seconds: 2),
                  top: isPortrait ? height * 0.2 : height * 0.1,
                  right: isAnimated
                      ? (isPortrait ? width * 0.14 : width * 0.25)
                      : -width * 0.9,
                  child: Image.asset(
                    'images/chat-app.jpeg',
                    height: isPortrait ? height * 0.3 : height * 0.4,
                    width: isPortrait ? width * 0.8 : width * 0.6,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: isPortrait ? height * 0.2 : height * 0.1,
                  child: Container(
                    width: width * 0.9,
                    height: height * 0.09,
                    child: ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      onPressed: () {
                        progressbar.showProgresBar(context);
                        try {
                          Authentication()
                              .signInWithGoogle(context)
                              .then((value) async {
                            Navigator.pop(context);
                            print(
                                "User name is  : ${value?.user} \n and additojn info is : ${value?.additionalUserInfo}");
                            if (value != null) {
                              if ((await APis.userExists())) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => HomeScreen()));
                              } else {
                                await APis.createUser().then((value) =>
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => HomeScreen())));
                              }
                            }
                          });
                        } catch (error) {
                          print(error.toString());
                        }
                      },
                      icon: Image.asset(
                        'images/google.png',
                        height: 40,
                        width: 40,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.only(left: 26),
                        child: Text(
                          "Sign In Using Google",
                          style: TextStyle(color: Colors.white, fontSize: 21),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
