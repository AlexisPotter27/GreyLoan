import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to LoginScreen after 3 seconds
    Future.delayed(const Duration(seconds: 7), () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LoginScreen(
                login: null,
              )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/main_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replace Icon with Image
              Image(
                image: AssetImage('assets/grey_loan.png'), // Path to your logo image
                height: 200,  // Adjust the size as necessary
                width: 200,   // Adjust the size as necessary
              ),
              //SizedBox(height: 10),
             /* Text(
                'Grey Loan',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),*/
              //SizedBox(height: 10),
              Text(
                'Your Financial Partner',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
