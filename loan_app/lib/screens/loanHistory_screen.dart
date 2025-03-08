import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/loan.dart';

class LoanHistoryScreen extends StatefulWidget {
  const LoanHistoryScreen({super.key});

  @override
  _LoanHistoryScreenState createState() => _LoanHistoryScreenState();
}

class _LoanHistoryScreenState extends State<LoanHistoryScreen> {
  String? country;

  @override
  void initState() {
    super.initState();
    _fetchCountry(); // Fetch user data once when the widget is initialized
  }

  Future<void> _fetchCountry() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('loanApplications')  // Adjust the collection to your user collection
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          country = userData['country'];  // Assuming 'country' is a field in your user document
        });
      }
    }
  }

  String getCountryIcon(String? country) {
    if (country == 'US') {
      return '\$'; // Dollar sign for US
    } else if (country == 'UK') {
      return '£'; // Pound sign for UK
    } else if (country == 'Germany') {
      return '€'; // Euro sign for Germany
    } else if (country == 'Poland') {
      return 'zł';
    } else if (country == 'Turkey') {
      return '₺';
    }
    return '\$'; // Default to dollar if country is not specified
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user UID
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Loan History'),
        backgroundColor: Colors.teal, // Set a color for the AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bek7.png'), // Replace with your image path
            fit: BoxFit.cover, // Ensure the image covers the whole screen
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('loanApplications')
              .where('userId', isEqualTo: user?.uid) // Fetch loans for the current user only
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong.'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No loan history found.'));
            }

            final loans = snapshot.data!.docs.map((doc) {
              return Loan.fromFirestore(doc.data() as Map<String, dynamic>);
            }).toList();

            return ListView.builder(
              itemCount: loans.length,
              itemBuilder: (context, index) {
                final loan = loans[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  elevation: 5,
                  color: Colors.white,
                  child: ListTile(
                    title: Text('Loan Status: ${loan.loanStatus}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        // Only show amount after the country is fetched
                        Text(
                          'Requested Amount: ${getCountryIcon(country)}${loan.requestedAmount.toStringAsFixed(2)}',
                        ),
                        Text('Tenure: ${loan.loanTenureMonths} months'),
                        Text('Loan Type: ${loan.selectedLoanType}'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
