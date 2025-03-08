import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/screens/dashboard.dart';

import 'loanTypeAmount_screen.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  //final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _routingController = TextEditingController();

  String? _selectedCountry;
  bool _isLoading = true; // To show a loading indicator while fetching data

  @override
  void initState() {
    super.initState();
    _fetchUserCountry();
  }

  // Fetch user country from Firestore
  Future<void> _fetchUserCountry() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('loanApplications')
            .doc(user.uid)
            .get();

        // Check if the user document exists and has a country field
        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            _selectedCountry = userDoc['country']; // Get country from Firestore
            _isLoading = false; // Stop loading after data is fetched
          });
        } else {
          // Handle case where country field doesn't exist or user doc is empty
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user country: $e');
      setState(() {
        _isLoading = false; // Stop loading even on error
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      //int creditScore = _generateCreditScore();
      User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('loanApplications')
          .doc(user!.uid)
          .set({
        'accountHolder': _accountHolderController.text,
        'bankName': _bankNameController.text,
        'accountNumber': _accountNumberController.text,
        'routing': _routingController.text,
        /*'employmentDuration': int.parse(_employmentDurationController.text),
        'industry_sector': _selectedIndustry,*/
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Bank Details'),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bek7.png'), // Replace with your image path
            fit: BoxFit.cover, // Ensure the image covers the entire screen
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Account Holder Name
                TextFormField(
                  controller: _accountHolderController,
                  decoration: InputDecoration(
                    hintText: 'Account Holder Name',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.security, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your account holder name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bank Name
                TextFormField(
                  controller: _bankNameController,
                  decoration: InputDecoration(
                    hintText: 'Bank Name',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.security, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your bank name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Account Number
                TextFormField(
                  controller: _accountNumberController,
                  decoration: InputDecoration(
                    hintText: 'Account Number',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.security, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your account number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Conditional Fields Based on Country
                if (_selectedCountry == 'US') ...[
                  // Routing Number for USA
                  TextFormField(
                    controller: _routingController,
                    decoration: InputDecoration(
                      hintText: 'Routing Number',
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.security, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter routing number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ] else if (_selectedCountry == 'UK') ...[
                  // Example for UK: Sort Code or other fields
                  TextFormField(
                    controller: _routingController,
                    decoration: const InputDecoration(
                      labelText: 'Sort Code (UK)',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter sort code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ] else if (_selectedCountry == 'Germany') ...[
                  // Example for Germany: IBAN or other fields
                  TextFormField(
                    controller: _routingController,
                    decoration: const InputDecoration(
                      labelText: 'IBAN (Germany)',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter IBAN';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ] else if (_selectedCountry == 'Poland') ...[
                  // Example for Poland: IBAN or other fields
                  TextFormField(
                    controller: _routingController,
                    decoration: const InputDecoration(
                      labelText: 'IBAN (Poland)',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter IBAN';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ] else if (_selectedCountry == 'Turkey') ...[
                  // Example for Turkey: IBAN or other fields
                  TextFormField(
                    controller: _routingController,
                    decoration: const InputDecoration(
                      labelText: 'IBAN (Turkey)',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter IBAN';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, show a success message or save the data
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bank Details Saved')));
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
