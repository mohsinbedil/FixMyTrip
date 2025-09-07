import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_my_trip/User/TripDetails.dart';

class CustomTripStatus extends StatelessWidget {
  const CustomTripStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final String userEmail = FirebaseAuth.instance.currentUser?.email ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Trip Status",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userBookings')
            .snapshots(), // Get all bookings
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
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
                "No bookings found.",
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            );
          }

          // Filter bookings where current user is the owner OR a member
          final userBookings = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            // Check if user is the trip owner
            final isOwner = data['userId'] == uid;
            
            // Check if user is a member (memberEmails contains user's email)
            final memberEmails = data['memberEmails'] as List<dynamic>?;
            final isMember = memberEmails != null && 
                            memberEmails.contains(userEmail);
            
            return isOwner || isMember;
          }).toList();

          if (userBookings.isEmpty) {
            return Center(
              child: Text(
                "No trips found for you.",
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: userBookings.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final isOwner = data['userId'] == uid;
              final memberEmails = data['memberEmails'] as List<dynamic>?;
              final isMember = memberEmails != null && memberEmails.contains(userEmail);

              return GestureDetector(
                onTap: () {
                  if (data['status'] == 'Rejected') {
                    _showRejectionAlert(context, data, doc.id);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripDetailsScreen(
                          tripData: data,
                          tripId: doc.id,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade900, Colors.black],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trip title + status chip
                        Row(
                          children: [
                            const Icon(Icons.flight_takeoff,
                                color: Colors.white70),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${data['origin']} → ${data['destination']}",
                                    style: GoogleFonts.quicksand(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
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
                                color: _statusColor(data['status']),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                data['status'] ?? "Pending",
                                style: GoogleFonts.poppins(
                                  color: (data['status'] == 'Confirmed' || data['status'] == 'Approved')
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Travel
                        Row(
                          children: [
                            const Icon(Icons.directions_car,
                                size: 18, color: Colors.orangeAccent),
                            const SizedBox(width: 6),
                            Text(
                              "Travel: ${data['travelMode']}",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Hotel
                        Row(
                          children: [
                            const Icon(Icons.hotel,
                                size: 18, color: Colors.cyanAccent),
                            const SizedBox(width: 6),
                            Text(
                              "Hotel: ${data['hotelType']}",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Food
                        Row(
                          children: [
                            const Icon(Icons.restaurant,
                                size: 18, color: Colors.greenAccent),
                            const SizedBox(width: 6),
                            Text(
                              "Food: ${data['foodType']}",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        // Member count (if applicable)
                        if (memberEmails != null && memberEmails.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.group,
                                    size: 16, color: Colors.purpleAccent),
                                const SizedBox(width: 6),
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

  void _showRejectionAlert(
      BuildContext context, Map<String, dynamic> tripData, String tripId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            "Trip Rejected",
            style: GoogleFonts.poppins(color: Colors.redAccent),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your trip from ${tripData['origin']} to ${tripData['destination']} has been rejected.",
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              if (tripData['rejectionReason'] != null)
                Text(
                  "Reason: ${tripData['rejectionReason']}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("OK",
                  style: GoogleFonts.poppins(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("View Details",
                  style: GoogleFonts.poppins(color: Colors.cyanAccent)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripDetailsScreen(
                      tripData: tripData,
                      tripId: tripId,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// ✅ Status Color Function
  Color _statusColor(String? status) {
    switch (status) {
      case 'Confirmed':
      case 'Approved':
        return const Color(0xFFC1FF72); // soft green
      case 'Rejected':
        return Colors.redAccent;
      case 'Pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}