import 'package:flutter/material.dart';

class SelectedUsersScreen extends StatelessWidget {
  final List<String> selectedUserEmails;

  const SelectedUsersScreen({Key? key, required this.selectedUserEmails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selected Users'),
      ),
      body: ListView.builder(
        itemCount: selectedUserEmails.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.person),
            title: Text(selectedUserEmails[index]),
          );
        },
      ),
    );
  }
}
