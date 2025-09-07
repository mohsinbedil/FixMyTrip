import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripBookingForm extends StatefulWidget {
  final String origin;
  final String destination;
  final String travelMode;
  final String hotelType;
  final String foodType;
  final int totalCost;
  final List<String> memberEmails;
  final int numPersons;

  const TripBookingForm({
    super.key,
    required this.origin,
    required this.destination,
    required this.travelMode,
    required this.hotelType,
    required this.foodType,
    required this.totalCost,
    this.memberEmails = const [],
    this.numPersons = 1,
  });

  @override
  State<TripBookingForm> createState() => _TripBookingFormState();
}

class _TripBookingFormState extends State<TripBookingForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailController.text = user.email ?? '';
    }
  }

  void submitBooking(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    if (nameController.text.isEmpty ||
        contactController.text.isEmpty ||
        emailController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all personal details.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('userBookings').add({
        'userId': user.uid,
        'name': nameController.text.trim(),
        'contact': contactController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
        'origin': widget.origin,
        'destination': widget.destination,
        'travelMode': widget.travelMode,
        'hotelType': widget.hotelType,
        'foodType': widget.foodType,
        'totalCost': widget.totalCost,
        'numPersons': widget.numPersons,
        'memberEmails': widget.memberEmails,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("Request Submitted", style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            "Your trip request has been submitted. The admin will review and approve it soon.\n\n"
            "You can check the status on the My Trip Status page.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("OK", style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting booking: ${e.toString()}")),
      );
    }
  }

  Widget inputField(
    String label,
    TextEditingController controller,
    TextInputType type,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.black54,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget buildTripDetails() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: Card(
        color: Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailTile(Icons.location_on, "From", widget.origin),
              _detailTile(Icons.flag, "To", widget.destination),
              _detailTile(Icons.directions_bus, "Travel Mode", widget.travelMode),
              _detailTile(Icons.hotel, "Hotel Type", widget.hotelType),
              _detailTile(Icons.fastfood, "Food Type", widget.foodType),
              const SizedBox(height: 12),
              _detailTile(Icons.people, "Number of Persons", "${widget.memberEmails.length + 1}"),
              const Divider(color: Colors.white24, height: 25),
              const Text("Total Cost:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              Text(
                "PKR ${widget.totalCost}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMembersSection() {
    if (widget.memberEmails.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Trip Members:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.memberEmails.length,
          itemBuilder: (context, index) {
            final email = widget.memberEmails[index];
            return Card(
              color: Colors.black54,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getAvatarColor(email),
                  foregroundColor: Colors.white,
                  child: Text(
                    email.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(email, style: const TextStyle(color: Colors.white)),
                contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getAvatarColor(String email) {
    final colors = [
      Colors.blue,
      Colors.redAccent,
      Colors.green,
      Colors.amber,
      Colors.purple,
      Colors.teal,
      Colors.deepOrange,
    ];
    return colors[email.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
    appBar: AppBar(
  backgroundColor: Colors.black,
  iconTheme: const IconThemeData(color: Colors.white), // ✅ makes back button white
  title: const Text(
    "Confirm Your Booking",
    style: TextStyle(color: Colors.white), // ✅ makes heading white
  ),
  centerTitle: true,
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Trip Details:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            buildTripDetails(),
            buildMembersSection(),
            const Divider(color: Colors.white54, height: 30),
            const Text(
              "Your Details:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            inputField("Full Name", nameController, TextInputType.name),
            inputField("Email", emailController, TextInputType.emailAddress),
            inputField("Contact Number", contactController, TextInputType.phone),
            inputField("Address", addressController, TextInputType.text),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => submitBooking(context),
                child: const Text("Submit Booking", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
