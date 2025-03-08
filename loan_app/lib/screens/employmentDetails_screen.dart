import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/screens/loanTypeAmount_screen.dart';
import '../widgets/showSnackbak.dart';

class EmploymentDetailsScreen extends StatefulWidget {
  const EmploymentDetailsScreen({super.key});

  @override
  State<EmploymentDetailsScreen> createState() => _EmploymentDetailsScreenState();
}

class _EmploymentDetailsScreenState extends State<EmploymentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _monthlyIncomeController = TextEditingController();
  final TextEditingController _employmentDurationController = TextEditingController();

  String? _employmentType;
  String? _selectedIndustry;
  String? country;


  final List<String> _employmentTypes = ["Salaried", "Self-Employed", "Freelancer"];
  final List<String> _industries = [
    "Information Technology",
    "Healthcare",
    "Education",
    "Finance",
    "Retail",
    "Manufacturing",
    "Construction",
    "Hospitality",
    "Transportation",
    "Other",
  ];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      //int creditScore = _generateCreditScore();
      User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('loanApplications')
          .doc(user!.uid)
          .set({ 
        'employmentType': _employmentType,
        'company_businessName': _companyNameController.text,
        'jobTitle_designation': _jobTitleController.text,
        'monthlyIncome': double.parse(_monthlyIncomeController.text),
        'employmentDuration': int.parse(_employmentDurationController.text),
        'industry_sector': _selectedIndustry,
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoanTypeAmountScreen()),
      );
    }
  }

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

 /* String currency() {
    Locale locale = Localizations.localeOf(context);
    var format = NumberFormat.simpleCurrency(locale: locale.toString());
    //print("CURRENCY SYMBOL ${format.currencySymbol}"); // $
    //print("CURRENCY NAME ${format.currencyName}"); // USD
    return format.currencySymbol;

  }*/

  /*Icon? getCountryIcon(String? country) {
    if (country == 'US') {
      return Icon(Icons.attach_money); // Dollar sign for US
    } else if (country == 'UK') {
      return Icon(Icons.currency_pound); // Pound sign for UK
    } else if (country == 'Germany') {
      return Icon(Icons.euro); // Euro sign for Germany
    } else if (country == 'Poland'){
      return Icon(FontAwesomeIcons.moneyBill1Wave);
    }
    return null;
  }*/

  String getCountryIcon(String? country) {
    _fetchUserDetails();
    if (country == 'US') {
      return '\$ '; // Dollar sign for US
    } else if (country == 'UK') {
      return '£ '; // Pound sign for UK
    } else if (country == 'Germany') {
      return '€ '; // Euro sign for Germany
    } else if (country == 'Poland') {
      return 'zł ';
    } else if (country == 'Turkey') {
      return '₺ ';
    }
    return '\$ ';
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(); // Fetch user details when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employment & Income Details"),
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
                  "Employment Type",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                DropdownButtonFormField<String>(
                  value: _employmentType,
                  items: _employmentTypes
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _employmentType = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select Employment Type",
                  ),
                  validator: (value) => value == null ? "Please select an employment type" : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _companyNameController,
                  decoration: InputDecoration(
                    labelText: "Company/Business Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your company/business name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _jobTitleController,
                  decoration: InputDecoration(
                    labelText: "Job Title / Designation",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your job title/designation";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _monthlyIncomeController,
                  decoration: InputDecoration(
                    labelText: "Monthly Income",
                    border: OutlineInputBorder(),
                    prefixText: getCountryIcon(country), // Call the method to get the icon dynamically
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your monthly income";
                    }
                    if (double.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _employmentDurationController,
                  decoration: InputDecoration(
                    labelText: "Employment Duration (Years of experience)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your employment duration";
                    }
                    if (int.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  "Industry/Sector",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedIndustry,
                  items: _industries
                      .map((industry) => DropdownMenuItem(
                    value: industry,
                    child: Text(industry),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedIndustry = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select Industry/Sector",
                  ),
                  validator: (value) => value == null ? "Please select an industry/sector" : null,
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Handle form submission
                        _submitForm();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Details submitted successfully!")),
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
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
