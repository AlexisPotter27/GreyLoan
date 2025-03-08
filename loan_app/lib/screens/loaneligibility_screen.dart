import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../data/countries_states_cities.dart';
import '../widgets/showSnackbak.dart';
import 'employmentDetails_screen.dart';

class LoanEligibilityScreen extends StatefulWidget {
  const LoanEligibilityScreen({super.key});

  @override
  State<LoanEligibilityScreen> createState() => _LoanEligibilityScreenState();
}

class _LoanEligibilityScreenState extends State<LoanEligibilityScreen> {
  // Selected values for dropdowns
  String? selectedCountry;
  String? selectedState;
  String? city;

  String? fullName;
  String? email;
  DateTime? selectedDate;
  String? selectedGender;

  // Global keys to handle form validation for each country
  final _usFormKey = GlobalKey<FormState>();
  final _ukFormKey = GlobalKey<FormState>();
  final _germanyFormKey = GlobalKey<FormState>();
  final _polandFormKey = GlobalKey<FormState>();
  final _turkeyFormKey = GlobalKey<FormState>();


  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;

  final List<Map<String, String>> countries = [
    {'name': 'Germany', 'code': 'de'},
    {'name': 'Poland', 'code': 'pl'},
    {'name': 'Turkey', 'code': 'tur'},
    {'name': 'UK', 'code': 'gb'},
    {'name': 'US', 'code': 'us'},
  ];

  // States and cities list based on selected country
  Map<String, List<String>>? states;
  List<String> cities = [];

  // Function to handle country change
  void onCountryChanged(String? country) {
    setState(() {
      selectedCountry = country;
      selectedState = null; // Reset state when country changes
      //selectedCity = null; // Reset city when country changes
      if (country != null) {
        states = countryStateCityData[country];
      } else {
        states = null;
      }
    });
  }

  // Function to handle state change
  void onStateChanged(String? state) {
    setState(() {
      selectedState = state;
      //selectedCity = null; // Reset city when state changes
      if (state != null) {
        cities = states?[state] ?? [];
      } else {
        cities = [];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          fullName = userData['fullname'];
          email = userData['email'];
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      if (mounted) {
        setState(() {
          selectedDate = picked;
        });
      }
    }
  }

  int _generateCreditScore() {
    Random random = Random();
    return random.nextInt(300) + 500;
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
      false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20), // Space between progress bar and text
              Text('Checking your credit report'),
            ],
          ),
        );
      },
    );
  }

  // Method to simulate some action that takes time
  Future<void> simulateAction(BuildContext context) async {
    showLoadingDialog(context);

    // Simulate a delay (for example, fetching credit report)
    await Future.delayed(Duration(seconds: 7));

    // Close the dialog after the delay
    Navigator.pop(context);
    _submitForm();
    _showConfirmationDialog();
  }

  // Method to validate all forms
  void _validateForms() {
    // Check if each form is valid
    bool usValid = _usFormKey.currentState?.validate() ?? false;
    bool ukValid = _ukFormKey.currentState?.validate() ?? false;
    bool germanyValid = _germanyFormKey.currentState?.validate() ?? false;
    bool polandValid = _polandFormKey.currentState?.validate() ?? false;
    bool turkeyValid = _turkeyFormKey.currentState?.validate() ?? false;

    // Show a message based on validation result
    if (usValid || ukValid || germanyValid || polandValid || turkeyValid) {
      simulateAction(context);
    } else {
      // One or more forms are invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields.')),
      );
    }
  }

  void _showConfirmationDialog() {
    setState(() {
      isLoading = true;
      Future.delayed(Duration(seconds: 3), () {});
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Credit Report Checked'),
          content: Text('Credit Check Passed!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator
                    .of(context)
                    .push;
                //_submitForm();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showSnackbar(context, 'User is not logged in');
      return;
    }

    // Validate and save US form
    if (_usFormKey.currentState != null &&
        _usFormKey.currentState!.validate()) {
      _usFormKey.currentState!.save();
      int creditScore = _generateCreditScore();

      await FirebaseFirestore.instance.collection('loanApplications').doc(
          user.uid).set({
        'fullName': fullName,
        'email': email,
        'country': selectedCountry,
        'dateOfBirth': selectedDate.toString(),
        'gender': selectedGender,
        'phoneNumber': phoneController.text,
        'creditScore': creditScore,
        'address': addressController.text,
        'city': city,
        'state': selectedState,
        'zip': zipController.text,
        'ssn_identifier': idController.text,
      }, SetOptions(merge: true));

      showSnackbar(context, 'Form submitted successfully!');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => EmploymentDetailsScreen()));
    }

    // Validate and save UK form
    if (_ukFormKey.currentState != null &&
        _ukFormKey.currentState!.validate()) {
      _ukFormKey.currentState!.save();
      int creditScore = _generateCreditScore();

      await FirebaseFirestore.instance.collection('loanApplications').doc(
          user.uid).set({
        'fullName': fullName,
        'email': email,
        'country': selectedCountry,
        'dateOfBirth': selectedDate.toString(),
        'gender': selectedGender,
        'phoneNumber': phoneController.text,
        'creditScore': creditScore,
        'address': addressController.text,
        'city': city,
        'state': selectedState,
        'zip': zipController.text,
        'ssn_identifier': idController.text,
      });

      showSnackbar(context, 'Form submitted successfully!');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => EmploymentDetailsScreen()));
    }

    // Validate and save Germany form
    if (_germanyFormKey.currentState != null &&
        _germanyFormKey.currentState!.validate()) {
      _germanyFormKey.currentState!.save();
      int creditScore = _generateCreditScore();

      await FirebaseFirestore.instance.collection('loanApplications').doc(
          user.uid).set({
        'fullName': fullName,
        'email': email,
        'country': selectedCountry,
        'dateOfBirth': selectedDate.toString(),
        'gender': selectedGender,
        'phoneNumber': phoneController.text,
        'creditScore': creditScore,
        'address': addressController.text,
        'city': city,
        'state': selectedState,
        'zip': zipController.text,
        'ssn_identifier': idController.text,
      });

      showSnackbar(context, 'Form submitted successfully!');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => EmploymentDetailsScreen()));
    }

    // Validate and save Germany form
    if (_polandFormKey.currentState != null &&
        _polandFormKey.currentState!.validate()) {
      _polandFormKey.currentState!.save();
      int creditScore = _generateCreditScore();

      await FirebaseFirestore.instance.collection('loanApplications').doc(
          user.uid).set({
        'fullName': fullName,
        'email': email,
        'country': selectedCountry,
        'dateOfBirth': selectedDate.toString(),
        'gender': selectedGender,
        'phoneNumber': phoneController.text,
        'creditScore': creditScore,
        'address': addressController.text,
        'city': city,
        'state': selectedState,
        'zip': zipController.text,
        'ssn_identifier': idController.text,
      });

      showSnackbar(context, 'Form submitted successfully!');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => EmploymentDetailsScreen()));
    }

    // Validate and save Germany form
    if (_turkeyFormKey.currentState != null &&
        _turkeyFormKey.currentState!.validate()) {
      _turkeyFormKey.currentState!.save();
      int creditScore = _generateCreditScore();

      await FirebaseFirestore.instance.collection('loanApplications').doc(
          user.uid).set({
        'fullName': fullName,
        'email': email,
        'country': selectedCountry,
        'dateOfBirth': selectedDate.toString(),
        'gender': selectedGender,
        'phoneNumber': phoneController.text,
        'creditScore': creditScore,
        'address': addressController.text,
        'city': city,
        'state': selectedState,
        'zip': zipController.text,
        'ssn_identifier': idController.text,
      });

      showSnackbar(context, 'Form submitted successfully!');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => EmploymentDetailsScreen()));
    }
  }

  Widget buildUSFormFields() {
    return Form(
      key: _usFormKey,
      child: Column(
        children: [
          //SizedBox(height: 16),
          //Text('Date of Birth:'),
          TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: selectedDate == null
                  ? 'Date of birth'
                  : '${selectedDate!.toLocal()}'.split(' ')[0],
              hintStyle: TextStyle(color: Colors.white70),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                ),
                onPressed: () => _selectDate(context),
              ),
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
              if (selectedDate == null) {
                return 'Please select your date of birth';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          //Text('Social Security Number (SSN):'),
          TextFormField(
            controller: idController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'SSN',
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
              if (value!.isEmpty) {
                return 'Please enter your SSN';
              } else if (value.length < 9 && value.length > 9) {
                return 'SSN must be 9 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          //Gender Selection
          DropdownButtonFormField<String>(
            hint: Text('Gender', style: TextStyle(color: Colors.white),),
            value: selectedGender,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.man_2_outlined, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value == null
                ? 'Please select your gender'
                : null,
            iconEnabledColor: Colors.white,
            onChanged: (value) {
              setState(() {
                selectedGender = value;
              });
            },
            items: ['Male', 'Female']
                .map((gender) =>
                DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender, selectionColor: Colors.black,),
                ))
                .toList(),
          ),
          SizedBox(height: 10),
          //Phone Number Text Field
          TextFormField(
            controller: phoneController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Phone number',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.phone, color: Colors.white),
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
              if (value!.isEmpty) {
                return 'Please enter your phone number';
              } else if (value.length < 10) {
                return 'Phone number must be at least 10 digits';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          //Text('Address'),
          TextFormField(
            controller: addressController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'House/ Block/ Building number',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.house, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value!.isEmpty ? 'House/ Block/ Building number' : null,
          ),
          SizedBox(height: 10),
          // State dropdown
          DropdownButtonFormField<String>(
            hint: Text('State', style: TextStyle(color: Colors.white70),),
            value: selectedState,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.map, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter State' : null,
            onChanged: onStateChanged,
            isExpanded: true,
            iconEnabledColor: Colors.white,
            items: states?.keys
                .map((state) =>
                DropdownMenuItem<String>(
                  value: state,
                  child: Text(state),
                ))
                .toList(),
          ),
          SizedBox(height: 10),
          // City dropdown
          TextFormField(
            controller: cityController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'City',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.location_city, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value!.isEmpty ? 'City' : null,
          ),
          /*DropdownButtonFormField<String>(
            hint: Text('City',style: TextStyle(color: Colors.white70),),
            value: selectedCity,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_city, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter City' : null,
            onChanged: (city) {
              setState(() {
                selectedCity = city;
              });
            },
            isExpanded: true,
            items: cities
                .map((city) =>
                DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                ))
                .toList(),
          ),*/
          SizedBox(height: 10),
          TextFormField(
            controller: zipController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'ZIP Code',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.pin, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter ZIP code' : null,
          ),
        ],
      ),
    );
  }

  Widget buildUKFormFields() {
    return Form(
      key: _ukFormKey,
      child: Column(
        children: [
          TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: selectedDate == null
                  ? 'Date of birth'
                  : '${selectedDate!.toLocal()}'.split(' ')[0],
              hintStyle: TextStyle(color: Colors.white70),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                ),
                onPressed: () => _selectDate(context),
              ),
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
              if (selectedDate == null) {
                return 'Please select your date of birth';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          //Text('National Insurance Number (NIN):'),
          TextFormField(
            controller: idController,
            style: TextStyle(
              color: Colors.white,
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'NIN',
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
              if (value!.isEmpty) {
                return 'Please enter your NIN';
              } else if (value.length < 9 && value.length > 9) {
                return 'NIN must be 9 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          //Gender Selection
          DropdownButtonFormField<String>(
            hint: Text('Gender', style: TextStyle(color: Colors.white70),),
            value: selectedGender,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.man_2_outlined, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value == null
                ? 'Please select your gender'
                : null,
            iconEnabledColor: Colors.white,
            onChanged: (value) {
              setState(() {
                selectedGender = value;
              });
            },
            items: ['Male', 'Female']
                .map((gender) =>
                DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                ))
                .toList(),
          ),
          SizedBox(height: 10),
          //Phone Number Text Field
          TextFormField(
            controller: phoneController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Phone number',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.phone, color: Colors.white),
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
              if (value!.isEmpty) {
                return 'Please enter your phone number';
              } else if (value.length < 10) {
                return 'Phone number must be at least 10 digits';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          //Text('Address'),
          TextFormField(
            controller: addressController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'House/ Block/ Building number',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.house, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value!.isEmpty ? 'House/ Block/ Building number' : null,
          ),
          SizedBox(height: 10),
          // State dropdown
          DropdownButtonFormField<String>(
            hint: Text('State', style: TextStyle(color: Colors.white70),),
            value: selectedState,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.map, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter City' : null,
            onChanged: onStateChanged,
            isExpanded: true,
            iconEnabledColor: Colors.white,
            items: states?.keys
                .map((state) =>
                DropdownMenuItem<String>(
                  value: state,
                  child: Text(state),
                ))
                .toList(),
          ),
          SizedBox(height: 10),
          // City dropdown
          TextFormField(
            controller: cityController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'City',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.location_city, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value!.isEmpty ? 'City' : null,
          ),
          /*DropdownButtonFormField<String>(
            hint: Text('City',style: TextStyle(color: Colors.white70),),
            value: selectedCity,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_city, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter City' : null,
            onChanged: (city) {
              setState(() {
                selectedCity = city;
              });
            },
            isExpanded: true,
            iconEnabledColor: Colors.white,
            items: cities
                .map((city) =>
                DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                ))
                .toList(),
          ),*/
          SizedBox(height: 10),
          //Zip Code
          TextFormField(
            controller: zipController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'ZIP Code',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.pin, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter ZIP code' : null,
          ),
        ],
      ),
    );
  }

  Widget buildGermanyFormFields() {
    return Form(
      key: _germanyFormKey,
      child: Column(
        children: [
          //Date of Birth
          TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: selectedDate == null
                  ? 'Date of birth'
                  : '${selectedDate!.toLocal()}'.split(' ')[0],
              hintStyle: TextStyle(color: Colors.white70),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                ),
                onPressed: () => _selectDate(context),
              ),
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
              if (selectedDate == null) {
                return 'Please select your date of birth';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          //Text('Steuer-ID (Tax ID):'),
          TextFormField(
            controller: idController,
            style: TextStyle(
              color: Colors.white,
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Steuer-ID (Tax ID)',
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
              if (value!.isEmpty) {
                return 'Please enter your Steuer-ID (Tax ID)';
              } else if (value.length < 11 && value.length > 11) {
                return 'Steuer-ID (Tax ID) must be 9 characters';
              }
              return null;
            },
          ),
          //Gender Selection
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            hint: Text('Gender', style: TextStyle(color: Colors.white70),),
            value: selectedGender,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.man_2_outlined, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value == null
                ? 'Please select your gender'
                : null,
            iconEnabledColor: Colors.white,
            onChanged: (value) {
              setState(() {
                selectedGender = value;
              });
            },
            items: ['Male', 'Female']
                .map((gender) =>
                DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                ))
                .toList(),
          ),
          SizedBox(height: 10),
          //Phone Number Text Field
          TextFormField(
            controller: phoneController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Phone number',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.phone, color: Colors.white),
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
              if (value!.isEmpty) {
                return 'Please enter your phone number';
              } else if (value.length < 10) {
                return 'Phone number must be at least 10 digits';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          //Text('Address'),
          TextFormField(
            controller: addressController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'House/ Block/ Building number',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.house, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value!.isEmpty ? 'House/ Block/ Building number' : null,
          ),
          SizedBox(height: 10),
          // State dropdown
          DropdownButtonFormField<String>(
            hint: Text('State', style: TextStyle(color: Colors.white70),),
            value: selectedState,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.map, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter State' : null,
            onChanged: onStateChanged,
            isExpanded: true,
            iconEnabledColor: Colors.white,
            items: states?.keys
                .map((state) =>
                DropdownMenuItem<String>(
                  value: state,
                  child: Text(state),
                ))
                .toList(),
          ),
          SizedBox(height: 10),
          // City dropdown
          TextFormField(
            controller: cityController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'City',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.location_city, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value!.isEmpty ? 'City' : null,
          ),
          /*DropdownButtonFormField<String>(
            hint: Text('City', style: TextStyle(color: Colors.white70),),
            value: selectedCity,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_city, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter City' : null,
            onChanged: (city) {
              setState(() {
                selectedCity = city;
              });
            },
            isExpanded: true,
            iconEnabledColor: Colors.white,
            items: cities
                .map((city) =>
                DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                ))
                .toList(),
          ),*/
          SizedBox(height: 10),
          //Zip Code
          TextFormField(
            controller: zipController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'ZIP Code',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.pin, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter ZIP code' : null,
          ),
        ],
      ),
    );
  }

  Widget buildPolandFormFields() {
    return Form(
      key: _polandFormKey,
      child: Column(
        children: [
          //Date of Birth
          TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: selectedDate == null
                  ? 'Date of birth'
                  : '${selectedDate!.toLocal()}'.split(' ')[0],
              hintStyle: TextStyle(color: Colors.white70),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                ),
                onPressed: () => _selectDate(context),
              ),
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
              if (selectedDate == null) {
                return 'Please select your date of birth';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          //Text('PESEL Number:'),
          TextFormField(
            controller: idController,
            style: TextStyle(
              color: Colors.white,
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'PESEL Number',
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
              if (value!.isEmpty) {
                return 'Please enter your PESEL Number';
              } else if (value.length < 11 && value.length > 11) {
                return 'PESEL Number must be 11 characters';
              }
              return null;
            },
          ),
          //Gender Selection
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            hint: Text('Gender', style: TextStyle(color: Colors.white70),),
            value: selectedGender,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.man_2_outlined, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value == null
                ? 'Please select your gender'
                : null,
            iconEnabledColor: Colors.white,
            onChanged: (value) {
              setState(() {
                selectedGender = value;
              });
            },
            items: ['Male', 'Female']
                .map((gender) =>
                DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                ))
                .toList(),
          ),
          SizedBox(height: 10),
          //Phone Number Text Field
          TextFormField(
            controller: phoneController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Phone number',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.phone, color: Colors.white),
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
              if (value!.isEmpty) {
                return 'Please enter your phone number';
              } else if (value.length < 10) {
                return 'Phone number must be at least 10 digits';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          //Text('Address'),
          TextFormField(
            controller: addressController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'House/ Block/ Building number',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.house, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value!.isEmpty ? 'House/ Block/ Building number' : null,
          ),
          SizedBox(height: 10),
          // State dropdown
          DropdownButtonFormField<String>(
            hint: Text('State', style: TextStyle(color: Colors.white70),),
            value: selectedState,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.map, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter State' : null,
            onChanged: onStateChanged,
            isExpanded: true,
            iconEnabledColor: Colors.white,
            items: states?.keys
                .map((state) =>
                DropdownMenuItem<String>(
                  value: state,
                  child: Text(state),
                ))
                .toList(),
          ),
          SizedBox(height: 10),
          // City dropdown
          TextFormField(
            controller: cityController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'City',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.location_city, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value!.isEmpty ? 'City' : null,
          ),
          /*DropdownButtonFormField<String>(
            hint: Text('City', style: TextStyle(color: Colors.white70),),
            value: selectedCity,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_city, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter City' : null,
            onChanged: (city) {
              setState(() {
                selectedCity = city;
              });
            },
            isExpanded: true,
            iconEnabledColor: Colors.white,
            items: cities
                .map((city) =>
                DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                ))
                .toList(),
          ),*/
          SizedBox(height: 10),
          //Zip Code
          TextFormField(
            controller: zipController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'ZIP Code',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.pin, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter ZIP code' : null,
          ),
        ],
      ),
    );
  }

  Widget buildTurkeyFormFields() {
    return Form(
      key: _turkeyFormKey,
      child: Column(
        children: [
          //Date of Birth
          TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: selectedDate == null
                  ? 'Date of birth'
                  : '${selectedDate!.toLocal()}'.split(' ')[0],
              hintStyle: TextStyle(color: Colors.white70),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                ),
                onPressed: () => _selectDate(context),
              ),
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
              if (selectedDate == null) {
                return 'Please select your date of birth';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          //Text('TCKN Number:'),
          TextFormField(
            controller: idController,
            style: TextStyle(
              color: Colors.white,
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'TCKN',
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
              if (value!.isEmpty) {
                return 'Please enter your TCKN';
              } else if (value.length < 11 && value.length > 11) {
                return 'TCKN must be 11 characters';
              }
              return null;
            },
          ),
          //Gender Selection
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            hint: Text('Gender', style: TextStyle(color: Colors.white70),),
            value: selectedGender,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.man_2_outlined, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value == null
                ? 'Please select your gender'
                : null,
            iconEnabledColor: Colors.white,
            onChanged: (value) {
              setState(() {
                selectedGender = value;
              });
            },
            items: ['Male', 'Female']
                .map((gender) =>
                DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                ))
                .toList(),
          ),
          SizedBox(height: 10),
          //Phone Number Text Field
          TextFormField(
            controller: phoneController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Phone number',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.phone, color: Colors.white),
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
              if (value!.isEmpty) {
                return 'Please enter your phone number';
              } else if (value.length < 10) {
                return 'Phone number must be at least 10 digits';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          //Text('Address'),
          TextFormField(
            controller: addressController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'House/ Block/ Building number',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.house, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value!.isEmpty ? 'House/ Block/ Building number' : null,
          ),
          SizedBox(height: 10),
          // State dropdown
          DropdownButtonFormField<String>(
            hint: Text('State', style: TextStyle(color: Colors.white70),),
            value: selectedState,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.map, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter State' : null,
            onChanged: onStateChanged,
            isExpanded: true,
            iconEnabledColor: Colors.white,
            items: states?.keys
                .map((state) =>
                DropdownMenuItem<String>(
                  value: state,
                  child: Text(state),
                ))
                .toList(),
          ),
          SizedBox(height: 10),
          // City dropdown
          TextFormField(
            controller: cityController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'City',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.location_city, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
            value!.isEmpty ? 'City' : null,
          ),
          /*DropdownButtonFormField<String>(
            hint: Text('City', style: TextStyle(color: Colors.white70),),
            value: selectedCity,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_city, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter City' : null,
            onChanged: (city) {
              setState(() {
                selectedCity = city;
              });
            },
            isExpanded: true,
            iconEnabledColor: Colors.white,
            items: cities
                .map((city) =>
                DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                ))
                .toList(),
          ),*/
          SizedBox(height: 10),
          //Zip Code
          TextFormField(
            controller: zipController,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'ZIP Code',
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.pin, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter ZIP code' : null,
          ),
        ],
      ),
    );
  }

  Widget buildDynamicForm() {
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          //key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              // Country dropdown
              DropdownButtonFormField<String>(
                value: selectedCountry,
                hint: Text(
                  'Country',
                  style: TextStyle(color: Colors.white),
                ),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: onCountryChanged,
                isExpanded: true,
                iconEnabledColor: Colors.white, // Set the arrow icon color here
                items: countries.map((country) {
                  return DropdownMenuItem(
                    value: country['name'],
                    child: Row(
                      children: [
                        CountryFlag.fromCountryCode(
                          country['code']!,
                          height: 24,
                          width: 32,
                          shape: const RoundedRectangle(8),
                        ),
                        SizedBox(width: 10),
                        Text(country['name']!),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: fullName),
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                readOnly: true,
              ),
              SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: email),
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.email, color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                //decoration: InputDecoration(labelText: 'Email Address'),
                readOnly: true,
              ),
              SizedBox(height: 12),

              if (selectedCountry == 'US') buildUSFormFields(),
              if (selectedCountry == 'UK') buildUKFormFields(),
              if (selectedCountry == 'Germany') buildGermanyFormFields(),
              if (selectedCountry == 'Poland') buildPolandFormFields(),
              if (selectedCountry == 'Turkey') buildTurkeyFormFields(),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _validateForms(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Check Eligibility',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('Loan Eligibility Form'),
        backgroundColor: Colors.white,
      ),
    body: Stack(
      children: [
        // Background Image
        Positioned.fill(

            /*colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.1), // Set your desired opacity here
              BlendMode.clear, // This blends the color to darken the image
            ),*/
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.png'), // Your image path here
                  fit: BoxFit.cover, // Ensure the image covers the entire container
                ),
              ),
            ),
          ),


        // Form content with padding and correct parent for Expanded
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
                Expanded(
                  child: buildDynamicForm(),
                ),
             ],
           ),
         ),
       ],
     ),
   );
  }
}


