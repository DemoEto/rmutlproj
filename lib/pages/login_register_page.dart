import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';




void main() => runApp(
  const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Login App",
    home: LoginPage(),
  ),
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String uid = user.uid;
      final String prefix = uid.substring(0, 1).toLowerCase();

      if (prefix == 't') {
        Navigator.pushReplacementNamed(context, '/teacherAttendanceView');
      } else if (prefix == 's') {
        Navigator.pushReplacementNamed(context, '/studentAttendanceView');
      } else if (prefix == 'p') {
        Navigator.pushReplacementNamed(context, '/parentAttendanceView');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถระบุประเภทผู้ใช้จาก UID ได้')),
        );
      }
    }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    if (_controllerPassword.text != _controllerConfirmPassword.text) {
      setState(() {
        errorMessage = 'Passwords do not match.';
      });
      return;
    }
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      setState(() {
        isLogin = true;
        errorMessage = 'Register success! Please login.';
      });
      _controllerPassword.clear();
      _controllerConfirmPassword.clear();
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  void click() {
    print("Button Clicked");
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Humm ? $errorMessage',
      style: const TextStyle(color: Colors.red, fontSize: 16),
      textAlign: TextAlign.center,
    );
  }

  Widget _submitButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        isLogin ? signInWithEmailAndPassword() : createUserWithEmailAndPassword();
      },
      child: Container(
        alignment: Alignment.center,
        width: screenWidth * 0.8,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
          ),
        ),
        child: Text(
          isLogin ? 'Login' : 'Register',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
          errorMessage = '';
        });
      },
      child: Text(
        isLogin ? 'Create an account' : 'Already have an account? Login',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _entryField(
    BuildContext context,
    String labelText,
    TextEditingController controller, {
    bool isPassword = false,
    IconData? icon,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey, size: 22),
          labelText: labelText,
          labelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _socialLoginButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: click,
          icon: const Icon(FontAwesomeIcons.facebook, color: Colors.blue, size: 30),
        ),
        IconButton(
          onPressed: () async {
            try {} catch (e) {
              print('Google Sign-in Error: $e');
              setState(() {
                errorMessage = 'Failed to sign in with Google.';
              });
            }
          },
          icon: const Icon(FontAwesomeIcons.google, color: Colors.redAccent, size: 30),
        ),
        IconButton(
          onPressed: click,
          icon: const Icon(
            FontAwesomeIcons.twitter,
            color: Colors.orangeAccent,
            size: 30,
          ),
        ),
        IconButton(
          onPressed: click,
          icon: const Icon(FontAwesomeIcons.linkedinIn, color: Colors.green, size: 30),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: Container(
            width: screenWidth,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purpleAccent, Colors.amber, Colors.blue],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: screenHeight * 0.04),
                SizedBox(
                  height: screenHeight * 0.2,
                  width: screenWidth * 0.6,
                  child: Image.asset("assets/images/login2.png"),
                ),
                SizedBox(height: screenHeight * 0.03),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLogin ? "Hello" : "Create Account",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isLogin
                              ? "Please Login to Your Account"
                              : "Create a new account",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _entryField(context, "Email Address", _controllerEmail,
                            icon: FontAwesomeIcons.envelope),
                        const SizedBox(height: 10),
                        _entryField(context, "Password", _controllerPassword,
                            isPassword: true, icon: FontAwesomeIcons.eyeSlash),
                        if (!isLogin)
                          Column(
                            children: [
                              const SizedBox(height: 10),
                              _entryField(context, "Confirm Password", _controllerConfirmPassword,
                                  isPassword: true, icon: FontAwesomeIcons.eye),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isLogin)
                                TextButton(
                                  onPressed: click,
                                  child: const Text(
                                    "Forget Password",
                                    style: TextStyle(color: Colors.deepOrange, fontSize: 14),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _errorMessage(),
                        const SizedBox(height: 15),
                        _submitButton(context),
                        const SizedBox(height: 10),
                        const Text(
                          "Or Login using Social Media Account",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        _socialLoginButtons(context),
                        //const SizedBox(height: 15),
                        _loginOrRegisterButton(),
                        //SizedBox(height: screenHeight * 0.05),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}