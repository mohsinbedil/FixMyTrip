import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripDetailsPage extends StatelessWidget {
  final String tripId;        // Trip ki unique id
  final String userEmail;     // Kisne trip banaya
  final String destination;   // Trip ka destination
  final String pickupPoint;   // Pickup point
  final String status;        // Status: Accepted, Pending, Completed

  const TripDetailsPage({
    super.key,
    required this.tripId,
    required this.userEmail,
    required this.destination,
    required this.pickupPoint,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Trip Details",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Trip ID:", tripId),
              _buildDetailRow("User Email:", userEmail),
              _buildDetailRow("Pickup Point:", pickupPoint),
              _buildDetailRow("Destination:", destination),
              _buildDetailRow("Status:", status),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 32),
                  ),
                  onPressed: () {
                    // ✅ Yahan Admin action kar sakta hai jaise Complete Trip
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Trip marked as Completed")),
                    );
                  },
                  child: Text(
                    "Mark as Completed",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFc1ff72),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
