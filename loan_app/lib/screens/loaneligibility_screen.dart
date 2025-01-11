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
  String? selectedCity;

  String? fullName;
  String? email;
  DateTime? selectedDate;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  final List<Map<String, String>> countries = [
    {'name': 'US', 'code': 'us'},
    {'name': 'UK', 'code': 'gb'},
    {'name': 'Germany', 'code': 'de'},
  ];

  // States and cities list based on selected country
  Map<String, List<String>>? states;
  List<String> cities = [];

  // Function to handle country change
  void onCountryChanged(String? country) {
    setState(() {
      selectedCountry = country;
      selectedState = null;  // Reset state when country changes
      selectedCity = null;   // Reset city when country changes
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
      selectedCity = null;  // Reset city when state changes
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

  /*void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 7),
      ),
    );
  }*/

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Submission'),
          content: Text('Are you sure you want to submit this form?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push;
                _submitForm();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      int creditScore = _generateCreditScore();
      User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('loanApplications')
          .doc(user!.uid)
          .set({
        'fullName': fullName,
        'email': email,
        'country': selectedCountry,
        'dateOfBirth': selectedDate.toString(),
        'creditScore': creditScore,
        'address': addressController.text,
        'city': selectedCity,
        'state': selectedState,
        'zip': zipController.text,
        'ssn_identifier': idController.text,
      });

      showSnackbar(context, 'Form submitted successfully!');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmploymentDetailsScreen()),
      );
    }
  }

  Widget _buildUSFormFields() {
    return Column(
      children: [
        //SizedBox(height: 16),
        //Text('Date of Birth:'),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: selectedDate == null
                ? 'Enter date of birth'
                : '${selectedDate!.toLocal()}'.split(' ')[0],
            hintStyle: TextStyle(color: Colors.black54),
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.lightBlue,),
              onPressed: () => _selectDate(context),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
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
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter SSN',
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: Icon(Icons.security, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your SSN';
            } else if (value.length < 9 && value.length > 9){
              return 'SSN must be 9 characters';
            }
            return null;
          },
        ),
        SizedBox(height: 10),
        //Text('Address'),
        //SizedBox(height: 8,),
        TextFormField(
          controller: addressController,
          decoration: InputDecoration(
            hintText: 'House/ Block/ Building number',
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: Icon(Icons.house, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'House/ Block/ Building number' : null,
        ),
        SizedBox(height: 10),
        // State dropdown
        //if (selectedCountry != null)
        DropdownButtonFormField<String>(
            hint: Text('Select State'),
            value: selectedState,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.black54),
              prefixIcon: Icon(Icons.map, color: Colors.lightBlue),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter State' : null,
            onChanged: onStateChanged,
            isExpanded: true,
            items: states?.keys
                .map((state) => DropdownMenuItem<String>(
              value: state,
              child: Text(state),
            ))
                .toList(),
          ),

        /*DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'State',
            prefixIcon: Icon(Icons.map, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          value: selectedState,
          items: countryStates['US']!.map((state) {
            return DropdownMenuItem(
              value: state,
              child: Text(state),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedState = value;
            });
          },
          validator: (value) => value == null ? 'Select state' : null,
        ),*/

        SizedBox(height: 10),

        // City dropdown
        //if (selectedState != null)
        DropdownButtonFormField<String>(
            hint: Text('Select City'),
            value: selectedCity,
            decoration: InputDecoration(
              hintText: 'City',
              labelStyle: TextStyle(color: Colors.black54),
              prefixIcon: Icon(Icons.location_city, color: Colors.lightBlue),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
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
                .map((city) => DropdownMenuItem<String>(
              value: city,
              child: Text(city),
            ))
                .toList(),
          ),

        /*TextFormField(
          controller: stateController,
          decoration: InputDecoration(
            hintText: 'City',
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: Icon(Icons.location_city, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Enter City' : null,
        ),*/
        SizedBox(height: 10),
        TextFormField(
          controller: zipController,
          decoration: InputDecoration(
            hintText: 'ZIP Code',
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: Icon(Icons.pin, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Enter ZIP code' : null,
        ),
      ],
    );
  }

  Widget _buildUKFormFields() {
    return Column(
      children: [
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: selectedDate == null
                ? 'Enter date of birth'
                : '${selectedDate!.toLocal()}'.split(' ')[0],
            hintStyle: TextStyle(color: Colors.black12),
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.lightBlue,),
              onPressed: () => _selectDate(context),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
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
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter NIN',
            labelStyle: TextStyle(color: Colors.black12),
            prefixIcon: Icon(Icons.security, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your NIN';
            } else if (value.length < 9 && value.length > 9){
              return 'NIN must be 9 characters';
            }
            return null;
          },
        ),
        SizedBox(height: 10),
        //Text('Address'),
        //SizedBox(height: 8,),
        TextFormField(
          controller: addressController,
          decoration: InputDecoration(
            hintText: 'House/ Block/ Building number',
            labelStyle: TextStyle(color: Colors.black12),
            prefixIcon: Icon(Icons.house, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'House/ Block/ Building number' : null,
        ),
        SizedBox(height: 10),
        // State dropdown
        //if (selectedCountry != null)
        DropdownButtonFormField<String>(
          hint: Text('Select State'),
          value: selectedState,
          decoration: InputDecoration(
            hintText: 'City',
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: Icon(Icons.map, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Enter City' : null,
          onChanged: onStateChanged,
          isExpanded: true,
          items: states?.keys
              .map((state) => DropdownMenuItem<String>(
            value: state,
            child: Text(state),
          ))
              .toList(),
        ),
        /*TextFormField(
          controller: stateController,
          decoration: InputDecoration(
            hintText: 'State/ Province',
            labelStyle: TextStyle(color: Colors.black12),
            prefixIcon: Icon(Icons.map, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Enter State/ Province' : null,
        ),*/
        SizedBox(height: 10),
        // City dropdown
        //if (selectedState != null)
        DropdownButtonFormField<String>(
          hint: Text('Select City'),
          value: selectedCity,
          decoration: InputDecoration(
            hintText: 'City',
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: Icon(Icons.location_city, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
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
              .map((city) => DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          ))
              .toList(),
        ),
        /*TextFormField(
          controller: cityController,
          decoration: InputDecoration(
            hintText: 'City',
            labelStyle: TextStyle(color: Colors.black12),
            prefixIcon: Icon(Icons.location_city, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Enter City' : null,
        ),*/
        SizedBox(height: 10),
        //Zip Code
        TextFormField(
          controller: zipController,
          decoration: InputDecoration(
            hintText: 'ZIP Code',
            labelStyle: TextStyle(color: Colors.black12),
            prefixIcon: Icon(Icons.pin, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Enter ZIP code' : null,
        ),

        /*TextFormField(
          controller: cityController,
          decoration: InputDecoration(
            labelText: 'City',
            prefixIcon: Icon(Icons.location_city, color: Colors.blueGrey),
          ),
          validator: (value) => value!.isEmpty ? 'Enter city' : null,
        ),
        TextFormField(
          controller: addressController,
          decoration: InputDecoration(
            labelText: 'Street Address',
            prefixIcon: Icon(Icons.streetview, color: Colors.blueGrey),
          ),
          validator: (value) => value!.isEmpty ? 'Enter street address' : null,
        ),*/
      ],
    );
  }

  Widget _buildGermanyFormFields() {
    return Column(
      children: [
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: selectedDate == null
                ? 'Enter date of birth'
                : '${selectedDate!.toLocal()}'.split(' ')[0],
            hintStyle: TextStyle(color: Colors.black12),
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.lightBlue,),
              onPressed: () => _selectDate(context),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
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
        //Text('SCHUFA Number:'),
        TextFormField(
          controller: idController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter SCHUFA Number',
            labelStyle: TextStyle(color: Colors.black12),
            prefixIcon: Icon(Icons.security, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your SCHUFA Number';
            } else if (value.length < 9 && value.length > 9){
              return 'SCHUFA Number must be 9 characters';
            }
            return null;
          },
        ),
        SizedBox(height: 10),
        //Text('Address'),
        //SizedBox(height: 8,),
        TextFormField(
          controller: addressController,
          decoration: InputDecoration(
            hintText: 'House/ Block/ Building number',
            labelStyle: TextStyle(color: Colors.black12),
            prefixIcon: Icon(Icons.house, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'House/ Block/ Building number' : null,
        ),
        SizedBox(height: 10),
        // State dropdown
        if (selectedCountry != null)
          DropdownButtonFormField<String>(
            hint: Text('Select State'),
            value: selectedState,
            decoration: InputDecoration(
              //hintText: 'City',
              labelStyle: TextStyle(color: Colors.black54),
              prefixIcon: Icon(Icons.map, color: Colors.lightBlue),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Enter State' : null,
            onChanged: onStateChanged,
            isExpanded: true,
            items: states?.keys
                .map((state) => DropdownMenuItem<String>(
              value: state,
              child: Text(state),
            ))
                .toList(),
          ),
        /*TextFormField(
          controller: stateController,
          decoration: InputDecoration(
            hintText: 'State/ Province',
            labelStyle: TextStyle(color: Colors.black12),
            prefixIcon: Icon(Icons.map, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Enter state' : null,
        ),*/
        SizedBox(height: 10),
        // City dropdown
        if (selectedState != null)
          DropdownButtonFormField<String>(
            hint: Text('Select City'),
            value: selectedCity,
            decoration: InputDecoration(
              hintText: 'City',
              labelStyle: TextStyle(color: Colors.black54),
              prefixIcon: Icon(Icons.location_city, color: Colors.lightBlue),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black26),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
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
                .map((city) => DropdownMenuItem<String>(
              value: city,
              child: Text(city),
            ))
                .toList(),
          ),
        /*TextFormField(
          controller: cityController,
          decoration: InputDecoration(
            hintText: 'City',
            labelStyle: TextStyle(color: Colors.black12),
            prefixIcon: Icon(Icons.location_city, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Enter City' : null,
        ),*/
        SizedBox(height: 10),
        //Zip Code
        TextFormField(
          controller: zipController,
          decoration: InputDecoration(
            hintText: 'ZIP Code',
            labelStyle: TextStyle(color: Colors.black12),
            prefixIcon: Icon(Icons.pin, color: Colors.lightBlue),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Enter ZIP code' : null,
        ),
      ],
    );
  }



  Widget _buildDynamicForm() {
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // Country dropdown
              DropdownButtonFormField<String>(
                value: selectedCountry,
                hint: Text('Select Country'),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: onCountryChanged,
                isExpanded: true,
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
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(Icons.person, color: Colors.lightBlue),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                readOnly: true,
              ),
              SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: email),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(Icons.email, color: Colors.lightBlue),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
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
              /*DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Country',
                ),
                value: selectedCountry,
                items: countries.map((country) {
                  return DropdownMenuItem(
                    value: country['name'],
                    child: Row(
                      children: [
                        CountryFlag.fromCountryCode(
                          country['code']!,
                          height: 20,
                          width: 30,
                        ),
                        SizedBox(width: 10),
                        Text(country['name']!),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value;
                  });
                },
              ),*/

              if (selectedCountry == 'US') _buildUSFormFields(),
              if (selectedCountry == 'UK') _buildUKFormFields(),
              if (selectedCountry == 'Germany') _buildGermanyFormFields(),
              SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: _showConfirmationDialog,
                  //_submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Changed button color
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: Text(
                    'Check Eligibility',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              /*ElevatedButton(
                onPressed: _showConfirmationDialog,
                //_submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Changed button color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: Text(
                  'Check Eligibility',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),*/

              /*ElevatedButton(
                onPressed: _showConfirmationDialog,
                child: Text('Submit'),
              ),*/
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
      ),
      //body: _buildDynamicForm(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        /*decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightGreenAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),*/
        child: _buildDynamicForm(),
      )
    );
  }
}
