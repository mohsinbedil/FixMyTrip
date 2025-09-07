import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String currentAddress = '';
  DateTime? dateOfBirth;
  String gender = 'Male';
  String nationality = '';
  List<String> travelPreferences = [];
  String preferredLanguage = 'English';
  String currencyPreference = 'USD';
  LatLng? selectedLocation;

  final List<String> travelOptions = [
    'Solo', 'Family', 'Luxury', 'Adventure', 'Backpacking'
  ];
  final List<String> languages = ['English', 'Urdu', 'French'];
  final List<String> currencies = ['USD', 'PKR', 'EUR'];

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BackgroundImageContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Color(0xFFD1A661)),
          title: Image.asset(
            'assets/images/fix_my_trip_banner.png',
            height: 40,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Create Account",
                    style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Join us and make your journeys easier.",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Full Name
                  PrimaryTextFormField(
                    label: "Full Name",
                    onChanged: (val) => fullName = val,
                  ),
                  const SizedBox(height: 15),

                  // Email
                  PrimaryTextFormField(
                    label: "Email Address",
                    onChanged: (val) => email = val,
                  ),
                  const SizedBox(height: 15),

                  // Password
                  PrimaryTextFormField(
                    label: "Password",
                    obscureText: true,
                    onChanged: (val) => password = val,
                  ),
                  const SizedBox(height: 15),

                  // Confirm Password
                  PrimaryTextFormField(
                    label: "Confirm Password",
                    obscureText: true,
                    onChanged: (val) => confirmPassword = val,
                  ),
                  const SizedBox(height: 15),

                  // Location Selector
                  GestureDetector(
                    onTap: () async {
                      LatLng? location = await _selectLocation();
                      if (location != null) {
                        setState(() {
                          selectedLocation = location;
                          currentAddress =
                              'Lat: ${location.latitude}, Lng: ${location.longitude}';
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: PrimaryTextFormField(
                        label: "Tap to select your location",
                        controller:
                            TextEditingController(text: currentAddress),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Date of Birth
                  ListTile(
                    tileColor: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    title: Text(
                      dateOfBirth == null
                          ? 'Pick Date of Birth'
                          : DateFormat('yyyy-MM-dd').format(dateOfBirth!),
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                    trailing:
                        const Icon(Icons.calendar_today, color: Colors.white70),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => dateOfBirth = picked);
                    },
                  ),
                  const SizedBox(height: 15),

                  // Gender
                  DropdownButtonFormField<String>(
                    value: gender,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g, style: const TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => gender = val!),
                    decoration: buildInputDecoration("Gender"),
                  ),
                  const SizedBox(height: 15),

                  // Nationality
                  PrimaryTextFormField(
                    label: "Nationality",
                    onChanged: (val) => nationality = val,
                  ),
                  const SizedBox(height: 15),

                  // Travel Preferences
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Travel Preferences",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: travelOptions.map((option) {
                      final isSelected = travelPreferences.contains(option);
                      return FilterChip(
                        label: Text(option,
                            style: GoogleFonts.poppins(
                                color:
                                    isSelected ? Colors.white : Colors.white70)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              travelPreferences.add(option);
                            } else {
                              travelPreferences.remove(option);
                            }
                          });
                        },
                        selectedColor: const Color(0xFFD1A661),
                        backgroundColor: const Color(0xFF2C2C2C),
                        checkmarkColor: Colors.black,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),

                  // Language
                  DropdownButtonFormField<String>(
                    value: preferredLanguage,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    items: languages
                        .map((l) => DropdownMenuItem(
                              value: l,
                              child:
                                  Text(l, style: const TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => preferredLanguage = val!),
                    decoration: buildInputDecoration("Preferred Language"),
                  ),
                  const SizedBox(height: 15),

                  // Currency
                  DropdownButtonFormField<String>(
                    value: currencyPreference,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    items: currencies
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child:
                                  Text(c, style: const TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => currencyPreference = val!),
                    decoration: buildInputDecoration("Currency Preference"),
                  ),
                  const SizedBox(height: 30),

                  // Register Button
                  GestureDetector(
                    onTap: _isLoading ? null : _registerUser,
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC1FF72),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "Create Account",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      labelStyle: GoogleFonts.poppins(color: Colors.white70),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'fullName': fullName,
          'email': email,
          'currentAddress': currentAddress,
          'location': selectedLocation != null
              ? GeoPoint(selectedLocation!.latitude, selectedLocation!.longitude)
              : null,
          'dateOfBirth': dateOfBirth,
          'gender': gender,
          'nationality': nationality,
          'travelPreferences': travelPreferences,
          'preferredLanguage': preferredLanguage,
          'currencyPreference': currencyPreference,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful")),
        );

        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign Up Failed: ${e.message}")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<LatLng?> _selectLocation() async {
    Position pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }
}

// Reusable dark TextFormField
class PrimaryTextFormField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const PrimaryTextFormField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Enter $label' : null,
      onChanged: onChanged,
    );
  }
}

// Background image container
class BackgroundImageContainer extends StatelessWidget {
  final Widget child;
  const BackgroundImageContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              "https://images.pexels.com/photos/917510/pexels-photo-917510.jpeg"),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
