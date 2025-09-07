import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AcceptedTripsPage extends StatelessWidget {
  const AcceptedTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Accepted Trips',
          style: GoogleFonts.quicksand(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
    .collection('trips')
    .where('status', isEqualTo: 'accepted')
    // .orderBy('acceptedAt', descending: true)
    .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFc1ff72)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No accepted trips yet.',
                style: GoogleFonts.quicksand(color: Colors.white70),
              ),
            );
          }

          final trips = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              final data = trip.data() as Map<String, dynamic>;

              Timestamp? startTimestamp = data['startDate'];
              Timestamp? endTimestamp = data['endDate'];
              String startDate = startTimestamp != null
                  ? "${startTimestamp.toDate().day.toString().padLeft(2,'0')}/${startTimestamp.toDate().month.toString().padLeft(2,'0')}/${startTimestamp.toDate().year}"
                  : "N/A";
              String endDate = endTimestamp != null
                  ? "${endTimestamp.toDate().day.toString().padLeft(2,'0')}/${endTimestamp.toDate().month.toString().padLeft(2,'0')}/${endTimestamp.toDate().year}"
                  : "N/A";

              return Card(
                color: const Color(0xFF1E1E1E),
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data['title'] ?? 'Unknown Trip'}',
                        style: GoogleFonts.quicksand(
                          color: const Color(0xFFc1ff72),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
               
                      Text(
                        'Accepted By: ${data['acceptedBy'] != null ? data['acceptedBy']['email'] : 'N/A'}',
                        style: GoogleFonts.quicksand(color: Colors.greenAccent),
                      ),
                      Text(
                        'Start: $startDate | End: $endDate',
                        style: GoogleFonts.quicksand(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      if (data['notes'] != null)
                        Text(
                          'Notes: ${data['notes']}',
                          style: GoogleFonts.quicksand(color: Colors.white60),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
