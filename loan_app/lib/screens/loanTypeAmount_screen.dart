import 'package:flutter/material.dart';

class LoanTypeAmountScreen extends StatefulWidget {
  const LoanTypeAmountScreen({super.key});

  @override
  _LoanTypeAmountScreenState createState() => _LoanTypeAmountScreenState();
}

class _LoanTypeAmountScreenState extends State<LoanTypeAmountScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLoanType;
  String? _selectedPurpose;
  double _requestedAmount = 5000; // Default loan amount
  int _loanTenureMonths = 12; // Default loan tenure in months

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
                  min: 1000,
                  max: 100000,
                  divisions: 100,
                  label: _requestedAmount.toStringAsFixed(0),
                  onChanged: (value) {
                    setState(() {
                      _requestedAmount = value;
                    });
                  },
                ),
                Text(
                  " Amount: ${_requestedAmount.toStringAsFixed(0)}",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  "Loan Tenure (Months)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Slider(
                  value: _loanTenureMonths.toDouble(),
                  min: 6,
                  max: 120,
                  divisions: 114,
                  label: "${_loanTenureMonths} Months",
                  onChanged: (value) {
                    setState(() {
                      _loanTenureMonths = value.toInt();
                    });
                  },
                ),
                Text(
                  "Tenure: ${_loanTenureMonths} Months",
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Details submitted successfully!"),
                          ),
                        );
                      }
                    },
                    child: Text("Submit"),
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
