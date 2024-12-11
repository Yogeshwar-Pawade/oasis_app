import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/api_service.dart';
import '../utils/session_manager.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  void _login() async {
    // Check for empty fields before proceeding
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError('Username and Password cannot be empty.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _apiService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      // Save the token and navigate to the Main Screen
      await SessionManager().saveToken(token);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      // Handle different error scenarios
      String errorMessage;
      if (e
          .toString()
          .contains('An unexpected error occurred. Please try again later.')) {
        errorMessage = 'Invalid username or password. Please try again.';
      } else if (e.toString().contains('Network error')) {
        errorMessage =
            'Unable to connect. Please check your internet connection.';
      } else {
        errorMessage = 'Invalid credentials';
      }
      _showError(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Top-left outward curved container
          Positioned(
            top: 0,
            left: 0,
            child: ClipPath(
              clipper: TopLeftOutwardCurveClipper(),
              child: Container(
                height: screenHeight * 0.30,
                width: screenWidth * 0.6,
                color: Colors.orange,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.1,
                    top: screenHeight * 0.05,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom clipped container with login form
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: BottomContainerClipper(),
              child: Container(
                height: screenHeight * 0.65,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 37, 37, 39),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.20,
                    left: screenWidth * 0.1,
                    right: screenWidth * 0.1,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Username TextField
                      TextField(
                        key: Key('usernameField'),
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.orange, width: 1.5),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // Password TextField
                      TextField(
                        key: Key('passwordField'),
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.orange, width: 1.5),
                          ),
                        ),
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            minimumSize: Size(
                              double.infinity,
                              screenHeight * 0.06,
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // Sign-Up Link
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            'Don\'t have an account? Sign up',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Top-left outward curved container clipper
class TopLeftOutwardCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.8,
      size.width,
      0,
    );
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Bottom container custom clipper
class BottomContainerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width / 2,
      0,
      size.width,
      size.height * 0.2,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
