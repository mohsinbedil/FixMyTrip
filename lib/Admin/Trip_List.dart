import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTripsPage extends StatelessWidget {
  const AdminTripsPage({super.key});

  Future<void> _deleteTrip(BuildContext context, String tripId) async {
    try {
      await FirebaseFirestore.instance.collection('trips').doc(tripId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Trip deleted successfully",
              style: GoogleFonts.quicksand()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to delete trip: $e",
              style: GoogleFonts.quicksand()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _editTrip(BuildContext context, String tripId, Map<String, dynamic> tripData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTripPage(tripId: tripId, tripData: tripData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'All Trips (Admin)',
          style: GoogleFonts.quicksand(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
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
            return Center(
              child: Text(
                'No trips added yet.',
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

              String status = data['status'] ?? 'pending';

              return Card(
                color: const Color(0xFF1E1E1E),
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        data['title'] ?? 'Unknown Trip',
                        style: GoogleFonts.quicksand(
                          color: const Color(0xFFc1ff72),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Price: ${data['price'] ?? 'N/A'} | Status: $status',
                        style: GoogleFonts.quicksand(
                          color: status == 'accepted'
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start: $startDate | End: $endDate',
                        style: GoogleFonts.quicksand(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      if (data['description'] != null)
                        Text(
                          data['description'],
                          style: GoogleFonts.quicksand(
                            color: Colors.white60,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 12),

                      // ✅ Edit & Delete Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _editTrip(context, trip.id, data),
                            icon: const Icon(Icons.edit, color: Colors.yellowAccent),
                            label: Text(
                              "Edit",
                              style: GoogleFonts.quicksand(color: Colors.yellowAccent),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _deleteTrip(context, trip.id),
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            label: Text(
                              "Delete",
                              style: GoogleFonts.quicksand(color: Colors.redAccent),
                            ),
                          ),
                        ],
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

// ✅ New Page to Edit Trip
class EditTripPage extends StatefulWidget {
  final String tripId;
  final Map<String, dynamic> tripData;

  const EditTripPage({super.key, required this.tripId, required this.tripData});

  @override
  State<EditTripPage> createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.tripData['title']);
    _descriptionController = TextEditingController(text: widget.tripData['description']);
    _priceController = TextEditingController(text: widget.tripData['price'].toString());
    _imageUrlController = TextEditingController(text: widget.tripData['imageUrl']);
    _startDate = (widget.tripData['startDate'] as Timestamp?)?.toDate();
    _endDate = (widget.tripData['endDate'] as Timestamp?)?.toDate();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  Future<void> _saveTrip() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) return;
    if (_startDate == null || _endDate == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('trips').doc(widget.tripId).update({
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "price": double.tryParse(_priceController.text.trim()) ?? 0,
        "imageUrl": _imageUrlController.text.trim(),
        "startDate": Timestamp.fromDate(_startDate!),
        "endDate": Timestamp.fromDate(_endDate!),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Trip updated successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to update trip: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Edit Trip"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(_titleController, "Title"),
            const SizedBox(height: 16),
            _buildTextField(_descriptionController, "Description", maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField(_priceController, "Price", keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_imageUrlController, "Image URL"),
            const SizedBox(height: 16),
            _buildDatePicker("Start Date", _startDate, () => _pickDate(isStart: true)),
            const SizedBox(height: 16),
            _buildDatePicker("End Date", _endDate, () => _pickDate(isStart: false)),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator(color: Color(0xFFc1ff72))
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: const Color(0xFFc1ff72),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Save Trip"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFc1ff72)),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFc1ff72)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? "$label: Not selected" : "$label: ${date.day}/${date.month}/${date.year}",
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.calendar_today, color: Color(0xFFc1ff72)),
          ],
        ),
      ),
    );
  }
}
