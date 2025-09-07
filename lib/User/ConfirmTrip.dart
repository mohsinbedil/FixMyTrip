import 'package:fix_my_trip/User/ExpenseSummary.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_my_trip/User/TripDetails.dart';

class ConfirmedTripsScreen extends StatelessWidget {
  const ConfirmedTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final String userEmail = FirebaseAuth.instance.currentUser?.email ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text("My Confirmed Trips", style: GoogleFonts.poppins(color: Colors.white,)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userBookings')
            .where('status', isEqualTo: 'Confirmed')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No confirmed trips found.",
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            );
          }

          // Filter confirmed trips where current user is owner OR member
          final confirmedTrips = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            // Check if user is the trip owner
            final isOwner = data['userId'] == uid;
            
            // Check if user is a member (memberEmails contains user's email)
            final memberEmails = data['memberEmails'] as List<dynamic>?;
            final isMember = memberEmails != null && 
                            memberEmails.contains(userEmail);
            
            return isOwner || isMember;
          }).toList();

          if (confirmedTrips.isEmpty) {
            return Center(
              child: Text(
                "No confirmed trips found for you.",
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: confirmedTrips.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final isOwner = data['userId'] == uid;
              final memberEmails = data['memberEmails'] as List<dynamic>?;
              final isMember = memberEmails != null && memberEmails.contains(userEmail);

              return GestureDetector(
                onTap: () => _showTripOptions(context, data, doc.id),
                child: Card(
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${data['origin']} → ${data['destination']}",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isOwner ? "Trip Owner" : "Trip Member",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Confirmed",
                                style: GoogleFonts.poppins(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTripDetailRow(
                            Icons.directions, "Travel Mode", data['travelMode']),
                        const SizedBox(height: 8),
                        _buildTripDetailRow(
                            Icons.hotel, "Accommodation", data['hotelType']),
                        const SizedBox(height: 8),
                        _buildTripDetailRow(
                            Icons.restaurant, "Food Preference", data['foodType']),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(
                              data['tripDate'] ?? "Date not specified",
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),
                          ],
                        ),
                        // Show member count if available
                        if (memberEmails != null && memberEmails.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.group,
                                    size: 16, color: Colors.purpleAccent),
                                const SizedBox(width: 8),
                                Text(
                                  "Members: ${memberEmails.length}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildTripDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(width: 12),
        Text(
          "$label: ",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _showTripOptions(BuildContext context, Map<String, dynamic> tripData, String tripId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("Trip Options", 
              style: GoogleFonts.poppins(color: Colors.white)),
          content: Text("What would you like to do with this trip?",
              style: GoogleFonts.poppins(color: Colors.white70)),
          actions: [
            TextButton(
              child: Text("View Details", 
                  style: GoogleFonts.poppins(color: Colors.greenAccent)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripDetailsScreen(tripData: tripData, tripId: tripId),
                  ),
                );
              },
            ),
            TextButton(
              child: Text("Expense Summary", 
                  style: GoogleFonts.poppins(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripExpenseSummaryScreen(tripId: tripId),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}