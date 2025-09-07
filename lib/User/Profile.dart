import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import './Login.dart';
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC1FF72)))
          : SingleChildScrollView(
              child: Column(
                children: [
// 🌟 Avatar full width container with gradient + shadow + green glow
Container(
  width: MediaQuery.of(context).size.width - 40, // ✅ input ke equal width
  margin: const EdgeInsets.all(16),
  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF1E1E1E), Colors.black],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      // 🔥 normal shadow
      BoxShadow(
        color: Colors.black.withOpacity(0.6),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
      // 💚 glowing green outer effect
      BoxShadow(
        color: const Color(0xFFc1ff72).withOpacity(0.4),
        blurRadius: 15,
        spreadRadius: 1,
      ),
    ],
  ),
  child: Column(
    children: [
      CircleAvatar(
        radius: 45,
        backgroundColor: Colors.grey[900],
        child: const Icon(Icons.person, size: 50, color: Colors.white70),
      ),
      const SizedBox(height: 12),
      Text(
        userData!['fullName'],
        style: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      Text(
        userData!['email'],
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionButton("Edit", Icons.edit, () {
            _openEditModal(context);
          }),
          const SizedBox(width: 12),
_actionButton("Log Out", Icons.logout, () async {
  await FirebaseAuth.instance.signOut();
  
  // Navigate to Login Page
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()), // replace with your login page widget
  );
}),

        ],
      ),
    ],
  ),
),

                  // 🌟 Info Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _infoCard(Icons.person, "Gender", userData!['gender']),
                        _infoCard(Icons.flag, "Nationality", userData!['nationality']),
                        _infoCard(Icons.language, "Language", userData!['preferredLanguage']),
                        _infoCard(Icons.attach_money, "Currency", userData!['currencyPreference']),
                        _infoCard(Icons.home, "Address", userData!['currentAddress']),
                        _infoCard(
                          Icons.cake,
                          "Date of Birth",
                          userData!['dateOfBirth'] != null
                              ? DateFormat('yyyy-MM-dd').format(userData!['dateOfBirth'].toDate())
                              : 'Not provided',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🌟 Travel Preferences Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Travel Preferences",
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: (userData!['travelPreferences'] as List<dynamic>)
                          .map<Widget>((pref) {
                        return Chip(
                          label: Text(pref, style: GoogleFonts.poppins(color: Colors.white)),
                          backgroundColor: Colors.grey[850],
                          side: const BorderSide(color: Color(0xFFC1FF72)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // 🌟 Action Button
  Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: Colors.black),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC1FF72),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }

  // 🌟 Info Card
  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC1FF72), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label: $value",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 Open Edit Modal
  void _openEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: EditProfileModal(
          userData: userData!,
          onSave: (updatedData) async {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .update(updatedData);
              Navigator.pop(context);
              fetchUserData(); // refresh
            }
          },
        ),
      ),
    );
  }
}

// ⚡ Improved Edit Modal
class EditProfileModal extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onSave;

  const EditProfileModal({super.key, required this.userData, required this.onSave});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController nationalityController;
  late TextEditingController languageController;
  late TextEditingController genderController;
  late TextEditingController currencyController;
  late TextEditingController addressController;
  late TextEditingController dobController;
  late TextEditingController travelPreferencesController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userData['fullName']);
    emailController = TextEditingController(text: widget.userData['email']);
    nationalityController = TextEditingController(text: widget.userData['nationality']);
    languageController = TextEditingController(text: widget.userData['preferredLanguage']);
    genderController = TextEditingController(text: widget.userData['gender']);
    currencyController = TextEditingController(text: widget.userData['currencyPreference']);
    addressController = TextEditingController(text: widget.userData['currentAddress']);
    dobController = TextEditingController(
      text: widget.userData['dateOfBirth'] != null
          ? DateFormat('yyyy-MM-dd').format(widget.userData['dateOfBirth'].toDate())
          : '',
    );
    travelPreferencesController = TextEditingController(
      text: (widget.userData['travelPreferences'] as List<dynamic>).join(', '),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    nationalityController.dispose();
    languageController.dispose();
    genderController.dispose();
    currencyController.dispose();
    addressController.dispose();
    dobController.dispose();
    travelPreferencesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime initialDate = widget.userData['dateOfBirth']?.toDate() ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFC1FF72),
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 16),
            Text("Edit Profile", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),

            buildTextField("Full Name", nameController),
            buildTextField("Email", emailController),
            buildTextField("Gender", genderController),
            buildTextField("Nationality", nationalityController),
            buildTextField("Preferred Language", languageController),
            buildTextField("Currency Preference", currencyController),
            buildTextField("Current Address", addressController),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(child: buildTextField("Date of Birth", dobController)),
            ),
            buildTextField("Travel Preferences (comma separated)", travelPreferencesController),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedData = {
                  'fullName': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'gender': genderController.text.trim(),
                  'nationality': nationalityController.text.trim(),
                  'preferredLanguage': languageController.text.trim(),
                  'currencyPreference': currencyController.text.trim(),
                  'currentAddress': addressController.text.trim(),
                  'dateOfBirth': Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(dobController.text)),
                  'travelPreferences': travelPreferencesController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                };

                widget.onSave(updatedData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC1FF72),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Save", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFC1FF72), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
