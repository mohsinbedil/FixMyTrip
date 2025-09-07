import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CutommTripBookingOrder extends StatelessWidget {
  const CutommTripBookingOrder({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.greenAccent;
      case 'Pending':
        return Colors.yellowAccent;
      case 'Rejected':
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'All User Bookings',
          style: GoogleFonts.quicksand(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userBookings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading data',
                    style: GoogleFonts.quicksand(color: Colors.white)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(0xFFc1ff72),
            ));
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return Center(
                child: Text('No bookings found',
                    style: GoogleFonts.quicksand(color: Colors.white70)));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;
              String status =
                  data.containsKey('status') ? data['status'] : 'Pending';

              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data['name']} - ${data['origin']} → ${data['destination']}',
                          style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFc1ff72)),
                        ),
                        const SizedBox(height: 8),
                        Text('Phone: ${data['contact'] ?? data['phone']}',
                            style:
                                GoogleFonts.quicksand(color: Colors.white70)),
                        Text('Email: ${data['email']}',
                            style:
                                GoogleFonts.quicksand(color: Colors.white70)),
                  
                        Text(
                            'Travel: ${data['travelMode']} | Hotel: ${data['hotelType']} | Food: ${data['foodType']}',
                            style:
                                GoogleFonts.quicksand(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text('Total Cost: PKR ${data['totalCost']}',
                            style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent)),
                        const Divider(color: Colors.white24, height: 20),
                        Text('Trip Members:',
                            style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70)),
                        if (data.containsKey('memberEmails') &&
                            (data['memberEmails'] as List).isNotEmpty)
                          ...List.generate((data['memberEmails'] as List).length,
                              (i) {
                            final email = (data['memberEmails'] as List)[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors
                                        .primaries[i % Colors.primaries.length],
                                    foregroundColor: Colors.white,
                                    child: Text(
                                      email[0].toUpperCase(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(email,
                                      style: GoogleFonts.quicksand(
                                          color: Colors.white70)),
                                ],
                              ),
                            );
                          }),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Status: ',
                                style: GoogleFonts.quicksand(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold)),
                            DropdownButton<String>(
                              value: status,
                              dropdownColor: const Color(0xFF1E1E1E),
                              style: TextStyle(color: _getStatusColor(status)),
                              items: ['Pending', 'Confirmed', 'Rejected']
                                  .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(
                                          s,
                                          style: TextStyle(
                                              color: _getStatusColor(s)),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (newStatus) async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('userBookings')
                                      .doc(bookings[index].id)
                                      .update({'status': newStatus});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Status updated to $newStatus')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Failed to update status')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
