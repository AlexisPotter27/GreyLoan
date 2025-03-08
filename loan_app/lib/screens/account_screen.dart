import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loan_app/screens/bankDetails_screen.dart';
import 'package:loan_app/screens/repayment_screen.dart';
import 'dashboard.dart';
import 'profile_screen.dart'; // Import the ProfileScreen

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final int _selectedIndex = 1;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
        break;
      case 1:
      // Stay on Profile screen
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RepaymentScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'), // Your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.teal),
                title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("View and edit your profile"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.teal),
                title: const Text("Card and Bank", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Manage your cards and bank accounts"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to Card and Bank Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BankDetailsScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.contact_support, color: Colors.teal),
                title: const Text("Contact Us", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Get support or ask a question"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to Contact Us Screen
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.info, color: Colors.teal),
                title: const Text("About Us", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Learn more about our company"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to About Us Screen
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                subtitle: const Text("Sign out of your account"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.redAccent),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  // Navigate back to Login Screen or Landing Page
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Loan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_rounded),
            label: 'Repayment',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
