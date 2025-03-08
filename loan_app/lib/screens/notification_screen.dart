import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  // Assuming that notifications are stored under the 'notifications' collection
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    // Fetch notifications from Firestore collection
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('notifications').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.teal,  // Make the AppBar transparent
        elevation: 0,  // Remove the shadow
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bek7.png'),  // URL of the background image
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchNotifications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Something went wrong!"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No notifications available", style: TextStyle(color: Colors.white,),));
              } else {
                var notifications = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(8.0),  // Add some padding to avoid content touching screen edges
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      var notification = notifications[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        child: ListTile(
                          leading: Icon(Icons.notifications),
                          title: Text(notification['title'] ?? 'No Title'),
                          subtitle: Text(notification['message'] ?? 'No message'),
                          trailing: Text(notification['timestamp'] != null
                              ? formatTimestamp(notification['timestamp'].toDate())
                              : 'Unknown'),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  String formatTimestamp(DateTime timestamp) {
    // Format the timestamp to a more user-friendly format
    return "${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}";
  }
}
