import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;

  const GroupDetailScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupRef = FirebaseFirestore.instance.collection('groups').doc(groupId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: groupRef.get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error loading group'));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) return Center(child: Text('Group not found'));

          final groupName = data['name'] ?? 'Unnamed Group';
          final members = List<String>.from(data['members'] ?? []);
          final creatorName = data['creatorName'] ?? 'N/A';
          final creatorEmail = data['creatorEmail'] ?? 'N/A';
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text('Group Name: $groupName', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Created By: $creatorName', style: TextStyle(fontSize: 16)),
                Text('Email: $creatorEmail', style: TextStyle(fontSize: 16)),
                if (createdAt != null)
                  Text('Created At: ${DateFormat.yMMMd().add_jm().format(createdAt)}',
                      style: TextStyle(fontSize: 16)),
                Divider(height: 30),
                Text('Members:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...members.map((email) => ListTile(
                      leading: Icon(Icons.person),
                      title: Text(email),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
