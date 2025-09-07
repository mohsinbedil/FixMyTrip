import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  final String tripId;

  const AddExpenseScreen({super.key, required this.tripId});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String _paymentMethod = 'Cash';

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Expense",
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: GoogleFonts.poppins(color: Colors.white70),
                  prefixText: '\$ ',
                  prefixStyle: GoogleFonts.poppins(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Field
              TextFormField(
                controller: _categoryController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: GoogleFonts.poppins(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: GoogleFonts.poppins(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Date Picker
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: ListTile(
                  title: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : 'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  trailing: Icon(Icons.calendar_today, color: Colors.white70),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colors.blueAccent,
                              onPrimary: Colors.white,
                              surface: Colors.grey,
                              onSurface: Colors.white,
                            ),
                            dialogBackgroundColor: Colors.grey[900],
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Payment Method Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    dropdownColor: Colors.grey[900],
                    style: GoogleFonts.poppins(color: Colors.white),
                    items: ['Cash', 'Credit Card', 'Debit Card', 'Bank Transfer']
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(
                                method,
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      labelStyle: GoogleFonts.poppins(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitExpense,
                  child: Text(
                    'Save Expense',
                    style: GoogleFonts.poppins(
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
    );
  }

  void _submitExpense() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      try {
        final timestamp = FieldValue.serverTimestamp();
        final category = _categoryController.text;
        final amount = double.parse(_amountController.text);
        
        // Add expense to expenses subcollection
        await FirebaseFirestore.instance
            .collection('userBookings')
            .doc(widget.tripId)
            .collection('expenses')
            .add({
              'amount': amount,
              'category': category,
              'description': _descriptionController.text,
              'date': _selectedDate,
              'paymentMethod': _paymentMethod,
              'createdAt': timestamp,
            });

        // Fetch the trip document to get all member emails
        final tripDoc = await FirebaseFirestore.instance
            .collection('userBookings')
            .doc(widget.tripId)
            .get();

        if (tripDoc.exists) {
          final tripData = tripDoc.data() as Map<String, dynamic>;
          final memberEmails = tripData['memberEmails'] as List<dynamic>? ?? [];
          final ownerUserId = tripData['userId'] as String?;
          
          // Get owner's email from user document
          String? ownerEmail;
          if (ownerUserId != null) {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(ownerUserId)
                .get();
            
            if (userDoc.exists) {
              final userData = userDoc.data() as Map<String, dynamic>;
              ownerEmail = userData['email'] as String?;
            }
          }

          // Create a set of all unique emails (owner + members)
          final allEmails = <String>{};
          if (ownerEmail != null) {
            allEmails.add(ownerEmail);
          }
          for (var email in memberEmails) {
            if (email is String) {
              allEmails.add(email);
            }
          }

          // Create notifications for each member email
          final batch = FirebaseFirestore.instance.batch();
          final notificationsRef = FirebaseFirestore.instance.collection('notifications');

          for (final email in allEmails) {
            final docRef = notificationsRef.doc();
            batch.set(docRef, {
              'title': 'New Expense: $category',
              'message': 'Expense of \$${amount.toStringAsFixed(2)} has been added to the trip',
              'userEmail': email,
              'tripId': widget.tripId,
              'timestamp': timestamp,
              'read': false,
              'type': 'expense',
              'createdBy': FirebaseAuth.instance.currentUser?.email,
            });
          }

          // Commit all notifications in a single batch
          await batch.commit();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Expense added successfully! Notifications sent to ${allEmails.length} members',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Trip not found',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error adding expense: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all required fields including date',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}