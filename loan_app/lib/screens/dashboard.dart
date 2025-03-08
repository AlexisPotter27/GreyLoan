import 'package:flutter/material.dart';
import 'package:loan_app/screens/account_screen.dart';
import 'package:loan_app/screens/notification_screen.dart';
import 'package:loan_app/screens/profile_screen.dart';
import 'package:loan_app/screens/repayment_screen.dart';
import '../handle/permission_handler.dart';
import 'loanHistory_screen.dart';
import 'loaneligibility_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  /// Request all required permissions
  Future<void> _requestPermissions() async {
    bool permissionsGranted = await PermissionHandler.requestMultiplePermissions();

    if (permissionsGranted) {
      print("All permissions granted!");
    } else {
      _showPermissionsAlert();
    }
  }

  /// Show an alert if permissions are denied
  void _showPermissionsAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Permissions Required"),
          content: Text(
              "Some permissions were denied. The app may not function properly without these permissions."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
  int _selectedIndex = 0;

  bool isLoading = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;  // Stay on the dashboard
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AccountScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RepaymentScreen()),
        );
        break;
    }
  }

  void _showConfirmationDialog() {
    setState(() {
      isLoading = true;
      Future.delayed(Duration(seconds: 5), () {});
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Loan Record on Your Profile'),
          content: Text('Either your loan application is on process, pending or rejected! '),
          actions: [

            /*TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),*/
            ElevatedButton(
              onPressed: () {
                Navigator
                    .of(context)
                    .pop();
                //_submitForm();
              },
              child: Center(
              child: Text('Ok'),
              )
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Main content area with padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header replacing AppBar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications, color: Colors.white),
                          onPressed: () {
                            // Handle notifications
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NotificationScreen()),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.account_circle, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20), // Add spacing after the header
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Loan Summary',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.monetization_on, color: Colors.blueAccent),
                            title: Text('Current Loan Balance'),
                            subtitle: Text('No Records'),
                          ),
                        ),
                        SizedBox(height: 10),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.calendar_today, color: Colors.green),
                            title: Text('Next Payment Due'),
                            subtitle: Text('No Records'),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoanEligibilityScreen()),
                                );
                              },
                              icon: Icon(Icons.add),
                              label: Text('Apply for Loan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                _showConfirmationDialog();
                              },
                              icon: Icon(Icons.payment),
                              label: Text('Repay Loan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoanHistoryScreen()),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(30),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.orangeAccent,
                                    radius: 30,
                                    child: Icon(Icons.history, color: Colors.white, size: 30),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('History'),
                              ],
                            ),
                            Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    print('Receipts button pressed');
                                  },
                                  borderRadius: BorderRadius.circular(30),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.purpleAccent,
                                    radius: 30,
                                    child: Icon(Icons.receipt, color: Colors.white, size: 30),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('Receipts'),
                              ],
                            ),
                            Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    print('Support button pressed');
                                  },
                                  borderRadius: BorderRadius.circular(30),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.redAccent,
                                    radius: 30,
                                    child: Icon(Icons.help, color: Colors.white, size: 30),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('Support'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
