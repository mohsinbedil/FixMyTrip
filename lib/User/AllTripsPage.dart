import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class AllTripsPage extends StatelessWidget {
  const AllTripsPage({super.key});

  Future<void> acceptTrip(BuildContext context, String tripId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
        'acceptedBy': {'uid': user.uid, 'email': user.email},
        'status': 'accepted', // ✅ Status is updated here
        'acceptedAt': FieldValue.serverTimestamp(), // Timestamp of acceptance
      });

      // Snackbar to show success
    } catch (e) {
      // Snackbar to show error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('All Trips'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Color(0xFFc1ff72),
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('trips')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFc1ff72)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No trips found',
                style: TextStyle(color: Colors.white70),
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
              String startDate =
                  startTimestamp != null
                      ? "${startTimestamp.toDate().day.toString().padLeft(2, '0')}/${startTimestamp.toDate().month.toString().padLeft(2, '0')}/${startTimestamp.toDate().year}"
                      : "N/A";
              String endDate =
                  endTimestamp != null
                      ? "${endTimestamp.toDate().day.toString().padLeft(2, '0')}/${endTimestamp.toDate().month.toString().padLeft(2, '0')}/${endTimestamp.toDate().year}"
                      : "N/A";

              return Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.grey[900]!, Colors.grey[850]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data['imageUrl'] != null)
                        Stack(
                          children: [
                            Image.network(
                              data['imageUrl'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['title'] ?? 'Unknown Trip'}',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Price ${data['price'] ?? 'Unknown Trip'}',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (data['description'] != null)
                              Text(
                                data['description'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            const SizedBox(height: 10),

                            // Start & End Date
                            Row(
                              children: [
                                const Icon(
                                  Icons.date_range,
                                  color: Color(0xFFc1ff72),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'From: $startDate  To: $endDate',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color(0xFFc1ff72),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            if (data['notes'] != null)
                              Text(
                                'Notes: ${data['notes']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white60,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // ✅ Buttons Row
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await acceptTrip(context, trip.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFc1ff72),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Accept Trip'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => TripDetailsPage(
                                                tripId: trip.id,
                                                tripData: data,
                                              ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFFc1ff72),
                                      ),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('View Details'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

class TripDetailsPage extends StatelessWidget {
  final String tripId;
  final Map<String, dynamic> tripData;

  const TripDetailsPage({
    super.key,
    required this.tripId,
    required this.tripData,
  });

  @override
  Widget build(BuildContext context) {
    // Safe conversion of Timestamps
    Timestamp? startTimestamp = tripData['startDate'] as Timestamp?;
    Timestamp? endTimestamp = tripData['endDate'] as Timestamp?;
    String startDate =
        startTimestamp != null
            ? "${startTimestamp.toDate().day.toString().padLeft(2, '0')}/${startTimestamp.toDate().month.toString().padLeft(2, '0')}/${startTimestamp.toDate().year}"
            : "N/A";
    String endDate =
        endTimestamp != null
            ? "${endTimestamp.toDate().day.toString().padLeft(2, '0')}/${endTimestamp.toDate().month.toString().padLeft(2, '0')}/${endTimestamp.toDate().year}"
            : "N/A";

    // Safe conversion for createdAt
    String createdAt =
        tripData['createdAt'] != null && tripData['createdAt'] is Timestamp
            ? (tripData['createdAt'] as Timestamp).toDate().toString()
            : 'N/A';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Trip Details"),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Color(0xFFc1ff72),
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tripData['imageUrl'] != null &&
                tripData['imageUrl'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  tripData['imageUrl'],
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            // ✅ Fixed: use tripData, not data
            Text(
              '${tripData['title'] ?? 'Unknown Trip'}',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            if (tripData['description'] != null &&
                tripData['description'].toString().isNotEmpty)
              Text(
                tripData['description'],
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
              ),
            const SizedBox(height: 15),
            // Start & End Date
            Row(
              children: [
                const Icon(
                  Icons.date_range,
                  color: Color(0xFFc1ff72),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'From: $startDate  To: $endDate',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: const Color(0xFFc1ff72),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (tripData['notes'] != null &&
                tripData['notes'].toString().isNotEmpty)
              Text(
                "Notes: ${tripData['notes']}",
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.white60),
              ),
            const SizedBox(height: 20),
            Text(
              "Trip Status: ${tripData['status'] ?? 'pending'}",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.orangeAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Created At: $createdAt",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
