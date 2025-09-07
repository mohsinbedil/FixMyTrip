import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripDetailsScreen extends StatelessWidget {
  final String tripId;
  final Map<String, dynamic> tripData;

  const TripDetailsScreen({super.key, required this.tripId, required this.tripData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Trip Details",
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userBookings')
            .doc(tripId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Trip not found',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            );
          }

          final tripData = snapshot.data!.data() as Map<String, dynamic>;
          final bool isRejected = tripData['status'] == 'Rejected';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeaderSection(tripData),
                const SizedBox(height: 24),
                
                if (isRejected) _buildRejectionBanner(tripData),
                if (isRejected) const SizedBox(height: 20),
                
                _buildDetailsCard(tripData),
                const SizedBox(height: 20),
                
                _buildSectionTitle("Travel Details"),
                _buildDetailRow("Mode", tripData['travelMode'] ?? 'Not specified'),
                _buildDetailRow("Departure", "From ${tripData['origin'] ?? 'Unknown'}"),
                _buildDetailRow("Arrival", "To ${tripData['destination'] ?? 'Unknown'}"),
                const SizedBox(height: 20),
                
                _buildSectionTitle("Accommodation"),
                _buildDetailRow("Hotel Type", tripData['hotelType'] ?? 'Not specified'),
                const SizedBox(height: 20),
                
                _buildSectionTitle("Food Preferences"),
                _buildDetailRow("Meal Plan", tripData['foodType'] ?? 'Not specified'),
                const SizedBox(height: 20),
                
                isRejected ? _buildRejectedStatusSection(tripData) : _buildStatusSection(tripData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRejectionBanner(Map<String, dynamic> tripData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[900]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[700]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Trip Rejected",
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (tripData['rejectionReason'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Reason: ${tripData['rejectionReason']}",
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedStatusSection(Map<String, dynamic> tripData) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Trip Status",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0,
            backgroundColor: Colors.grey[800],
            color: Colors.redAccent,
            minHeight: 8,
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent,
                  ),
                  child: const Icon(Icons.close, size: 24, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rejected",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
                if (tripData['rejectionReason'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    "Reason: ${tripData['rejectionReason']}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> tripData) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Icon(
            tripData['status'] == 'Rejected' 
              ? Icons.cancel_rounded 
              : Icons.flight_takeoff_rounded,
            size: 32,
            color: tripData['status'] == 'Rejected' ? Colors.redAccent : Colors.blueAccent,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${tripData['origin'] ?? 'Unknown'} → ${tripData['destination'] ?? 'Unknown'}",
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Trip ID: #${tripData['id']?.toString().substring(0, 8) ?? 'N/A'}",
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(tripData['status']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tripData['status'] ?? "Pending",
              style: GoogleFonts.poppins(
                color: _statusColor(tripData['status']),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Map<String, dynamic> tripData) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          _buildInfoRow(Icons.calendar_today, "Trip Date", 
              _formatDate(tripData['startDate'], tripData['endDate'])),
          const Divider(height: 24, thickness: 0.5, color: Colors.grey),
          _buildInfoRow(Icons.person, "Travelers", 
              tripData['memberEmails']?.toString() ?? 'Not specified'),
          const Divider(height: 24, thickness: 0.5, color: Colors.grey),
          _buildInfoRow(Icons.credit_card, "Total Cost", 
              "\$${tripData['totalCost']?.toStringAsFixed(2) ?? '0.00'}"),
        ],
      ),
    );
  }

  String _formatDate(dynamic startDate, dynamic endDate) {
    try {
      final start = startDate is Timestamp ? startDate.toDate() : null;
      final end = endDate is Timestamp ? endDate.toDate() : null;
      
      if (start != null && end != null) {
        return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
      } else if (start != null) {
        return '${start.day}/${start.month}/${start.year}';
      }
      return 'Not specified';
    } catch (e) {
      return 'Not specified';
    }
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.quicksand(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(Map<String, dynamic> tripData) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Trip Status",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _getStatusProgress(tripData['status']),
            backgroundColor: Colors.grey[800],
            color: _statusColor(tripData['status']),
            minHeight: 8,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusStep("Pending", 1, tripData['status']),
              _buildStatusStep("Confirmed", 2, tripData['status']),
              _buildStatusStep("In Progress", 3, tripData['status']),
              _buildStatusStep("Completed", 4, tripData['status']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep(String label, int step, String? currentStatus) {
    int currentStep = _getStatusStep(currentStatus);
    bool isCompleted = step <= currentStep;
    bool isCurrent = step == currentStep;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? _statusColor(currentStatus) : Colors.grey[700],
            border: isCurrent
                ? Border.all(color: _statusColor(currentStatus), width: 3)
                : null,
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: isCompleted ? Colors.white : Colors.grey,
          ),
        ),
      ],
    );
  }

  int _getStatusStep(String? status) {
    switch (status) {
      case 'Pending':
        return 1;
      case 'Confirmed':
      case 'Approved':
        return 2;
      case 'In Progress':
        return 3;
      case 'Completed':
        return 4;
      default:
        return 1;
    }
  }

  double _getStatusProgress(String? status) {
    return _getStatusStep(status) / 4;
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Confirmed':
      case 'Approved':
        return const Color(0xFFC1FF72); // soft green
      case 'In Progress':
        return Colors.orangeAccent;
      case 'Completed':
        return Colors.blueAccent;
      case 'Rejected':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}