import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

class AddCustomTripsDetails extends StatefulWidget {
  const AddCustomTripsDetails({super.key});

  @override
  _AddCustomTripsDetailsState createState() => _AddCustomTripsDetailsState();
}

class _AddCustomTripsDetailsState extends State<AddCustomTripsDetails> {
  String? selectedOrigin;
  String? selectedDestination;
  List<String> cities = [];

  // Travel
  final airTravelController = TextEditingController();
  final trainTravelController = TextEditingController();
  final roadTravelController = TextEditingController();

  // Hotel
  final lowHotelController = TextEditingController();
  final mediumHotelController = TextEditingController();
  final highHotelController = TextEditingController();

  // Food
  final lowFoodController = TextEditingController();
  final mediumFoodController = TextEditingController();
  final highFoodController = TextEditingController();

  int numPersons = 1;
  int totalCostPerPerson = 0;
  int totalCostAll = 0;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  Future<void> fetchCities() async {
    final snapshot = await FirebaseFirestore.instance.collection('cities').get();
    final List<String> cityNames =
        snapshot.docs.map((doc) => doc['name'] as String).toList();

    setState(() {
      cities = cityNames;
    });
  }

  Future<void> calculateTravelCostBasedOnDistance() async {
    if (selectedOrigin == null || selectedDestination == null) return;

    final citiesSnap = await FirebaseFirestore.instance
        .collection('cities')
        .where('name', whereIn: [selectedOrigin, selectedDestination])
        .get();

    if (citiesSnap.docs.length < 2) return;

    LatLng? originLatLng;
    LatLng? destLatLng;

    for (var doc in citiesSnap.docs) {
      final data = doc.data();
      if (data['name'] == selectedOrigin) {
        originLatLng = LatLng(data['lat'], data['lng']);
      } else if (data['name'] == selectedDestination) {
        destLatLng = LatLng(data['lat'], data['lng']);
      }
    }

    if (originLatLng == null || destLatLng == null) return;

    final distance =
        Distance().as(LengthUnit.Kilometer, originLatLng, destLatLng);
    final airRate = 30; // PKR per km
    final trainRate = 10;
    final roadRate = 7;

    setState(() {
      airTravelController.text = (distance * airRate).round().toString();
      trainTravelController.text = (distance * trainRate).round().toString();
      roadTravelController.text = (distance * roadRate).round().toString();
    });

    calculatePreviewCost();
  }

  void calculatePreviewCost() {
    final air = int.tryParse(airTravelController.text) ?? 0;
    final train = int.tryParse(trainTravelController.text) ?? 0;
    final road = int.tryParse(roadTravelController.text) ?? 0;

    final lowHotel = int.tryParse(lowHotelController.text) ?? 0;
    final mediumHotel = int.tryParse(mediumHotelController.text) ?? 0;
    final highHotel = int.tryParse(highHotelController.text) ?? 0;

    final lowFood = int.tryParse(lowFoodController.text) ?? 0;
    final mediumFood = int.tryParse(mediumFoodController.text) ?? 0;
    final highFood = int.tryParse(highFoodController.text) ?? 0;

    final travel = air + train + road;
    final hotel = lowHotel + mediumHotel + highHotel;
    final food = lowFood + mediumFood + highFood;

    final perPerson = travel + hotel + food;
    final total = perPerson * numPersons;

    setState(() {
      totalCostPerPerson = perPerson;
      totalCostAll = total;
    });
  }

  void saveCityRoute() async {
    if (selectedOrigin == null || selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Origin and Destination are required')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('cityRoutes').add({
      'originCity': selectedOrigin,
      'destinationCity': selectedDestination,
      'numPersons': numPersons,
      'totalCostPerPerson': totalCostPerPerson,
      'totalCostAll': totalCostAll,
      'travelCost': {
        'air': int.tryParse(airTravelController.text) ?? 0,
        'train': int.tryParse(trainTravelController.text) ?? 0,
        'road': int.tryParse(roadTravelController.text) ?? 0,
      },
      'hotelCost': {
        'low': int.tryParse(lowHotelController.text) ?? 0,
        'medium': int.tryParse(mediumHotelController.text) ?? 0,
        'high': int.tryParse(highHotelController.text) ?? 0,
      },
      'foodCost': {
        'low': int.tryParse(lowFoodController.text) ?? 0,
        'medium': int.tryParse(mediumFoodController.text) ?? 0,
        'high': int.tryParse(highFoodController.text) ?? 0,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('✅ City Route with all details saved successfully')),
    );

    setState(() {
      selectedOrigin = null;
      selectedDestination = null;
      numPersons = 1;
      totalCostPerPerson = 0;
      totalCostAll = 0;
    });

    airTravelController.clear();
    trainTravelController.clear();
    roadTravelController.clear();
    lowHotelController.clear();
    mediumHotelController.clear();
    highHotelController.clear();
    lowFoodController.clear();
    mediumFoodController.clear();
    highFoodController.clear();
  }

  Widget sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 8),
        child: Text(title,
            style: GoogleFonts.quicksand(
                color: const Color(0xFFc1ff72),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      );

  Widget categoryInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFc1ff72)),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFc1ff72), width: 2)),
        ),
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.number,
        onChanged: (_) => calculatePreviewCost(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title:
            Text('Add City Route', style: GoogleFonts.quicksand(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('Select Origin City'),
            DropdownButtonFormField<String>(
              value: selectedOrigin,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              hint: const Text('Choose origin', style: TextStyle(color: Colors.white70)),
              items: cities
                  .map((city) =>
                      DropdownMenuItem(value: city, child: Text(city)))
                  .toList(),
              onChanged: (val) {
                setState(() => selectedOrigin = val);
                calculateTravelCostBasedOnDistance();
              },
            ),
            sectionTitle('Select Destination City'),
            DropdownButtonFormField<String>(
              value: selectedDestination,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              hint: const Text('Choose destination',
                  style: TextStyle(color: Colors.white70)),
              items: cities
                  .map((city) =>
                      DropdownMenuItem(value: city, child: Text(city)))
                  .toList(),
              onChanged: (val) {
                setState(() => selectedDestination = val);
                calculateTravelCostBasedOnDistance();
              },
            ),
            sectionTitle('Number of Persons'),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Enter number of persons',
                  labelStyle: const TextStyle(color: Color(0xFFc1ff72)),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFc1ff72), width: 2)),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    numPersons = int.tryParse(val) ?? 1;
                    if (numPersons < 1) numPersons = 1;
                    calculatePreviewCost();
                  });
                },
              ),
            ),
            sectionTitle('Travel Cost (auto-calculated)'),
            categoryInput('By Air', airTravelController),
            categoryInput('By Train', trainTravelController),
            categoryInput('By Road', roadTravelController),
            sectionTitle('Hotel Cost'),
            categoryInput('Low Budget', lowHotelController),
            categoryInput('Medium Budget', mediumHotelController),
            categoryInput('High Budget', highHotelController),
            sectionTitle('Food Cost'),
            categoryInput('Low Budget', lowFoodController),
            categoryInput('Medium Budget', mediumFoodController),
            categoryInput('High Budget', highFoodController),
            const SizedBox(height: 20),
            Text('Cost per person: PKR $totalCostPerPerson',
                style: GoogleFonts.quicksand(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            Text('Total cost for $numPersons persons: PKR $totalCostAll',
                style: GoogleFonts.quicksand(
                    color: const Color(0xFFc1ff72),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveCityRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: const Color(0xFFc1ff72),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Save City Route',
                    style: GoogleFonts.quicksand(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
