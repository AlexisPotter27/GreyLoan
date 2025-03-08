import 'package:flutter/material.dart';
import 'package:loan_app/screens/dashboard.dart';

class LoanProcessingScreen extends StatelessWidget {
  const LoanProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loan Processing"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.hourglass_top,
              size: 100,
              color: Colors.teal,
            ),
            const SizedBox(height: 24),
            const Text(
              "Loan Application Under Processing",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Thank you for applying for a loan. Your application is currently being processed. Please wait while we verify your KYC details and finalize the approval process.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.teal),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Action for returning to the home screen or another relevant page
                // Navigate to the LoanHistoryScreen when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text("Return to Home",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
