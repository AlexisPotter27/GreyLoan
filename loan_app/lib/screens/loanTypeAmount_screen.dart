import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/screens/loanProcessing_screen.dart';

class LoanTypeAmountScreen extends StatefulWidget {
  const LoanTypeAmountScreen({super.key});

  @override
  State<LoanTypeAmountScreen> createState() => _LoanTypeAmountScreenState();
}

class _LoanTypeAmountScreenState extends State<LoanTypeAmountScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _loanStatus;
  String? _selectedLoanType;
  String? _selectedPurpose;
  double _requestedAmount = 1000; // Default loan amount
  int _loanTenureMonths = 6; // Default loan tenure in months

  String? country;

  final List<String> _loanTypes = [
    "Personal",
    "Business",
    "Home",
    "Education",
    "Auto",
    "Medical",
  ];

  final List<String> _purposes = [
    "Education",
    "Home Renovation",
    "Business Expansion",
    "Debt Consolidation",
    "Medical Emergency",
    "Vacation",
    "Other",
  ];

  Future<void> _fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('loanApplications')
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          country = userData['country'];
        });
      }
    }
  }

  String getCountryIcon(String? country) {
    _fetchUserDetails();
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
    return '\$';
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _loanStatus = 'Pending';
      //int creditScore = _generateCreditScore();
      User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('loanApplications')
          .doc(user!.uid)
          .set({
        'userId': user.uid,
        'loanStatus': _loanStatus,
        'selectedLoanType': _selectedLoanType,
        'selectedPurpose': _selectedPurpose.toString(),
        'requestedAmount': double.parse(_requestedAmount.toString()),
        'loanTenureMonths': double.parse(_loanTenureMonths.toString()),
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoanProcessingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Loan Type & Amount"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Type of Loan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedLoanType,
                  items: _loanTypes
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLoanType = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select Loan Type",
                  ),
                  validator: (value) => value == null ? "Please select a loan type" : null,
                ),
                SizedBox(height: 16),
                Text(
                  "Requested Loan Amount",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Slider(
                  value: _requestedAmount,
                  min: 200,
                  max: 10000,
                  divisions: 100,
                  label: _requestedAmount.toStringAsFixed(0),
                  onChanged: (value) {
                    setState(() {
                      _requestedAmount = value;
                    });
                  },
                ),
                Text(
                  " Amount:${getCountryIcon(country)}${_requestedAmount.toStringAsFixed(0)}",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  "Loan Tenure (Months)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Slider(
                  value: _loanTenureMonths.toDouble(),
                  min: 2,
                  max: 24,
                  divisions: 114,
                  label: "$_loanTenureMonths Months",
                  onChanged: (value) {
                    setState(() {
                      _loanTenureMonths = value.toInt();
                    });
                  },
                ),
                Text(
                  "Tenure: $_loanTenureMonths Months",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  "Purpose of Loan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedPurpose,
                  items: _purposes
                      .map((purpose) => DropdownMenuItem(
                    value: purpose,
                    child: Text(purpose),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPurpose = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select Purpose of Loan",
                  ),
                  validator: (value) => value == null ? "Please select a purpose" : null,
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Handle form submission
                        _submitForm();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Details submitted successfully!"),
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoanProcessingScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Submit",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
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

