import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import './CustomTripBooking.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import './TravelHomePage.dart';

class CustomTrip extends StatefulWidget {
  @override
  _CustomTripState createState() => _CustomTripState();
}

class _CustomTripState extends State<CustomTrip> {
  String? selectedOrigin;
  String? selectedDestination;
  String travelMode = 'air';
  String hotelType = 'low';
  String foodType = 'low';
  int numPersons = 1;

  List<String> originCities = [];
  List<String> destinationCities = [];
  List<String> allUserEmails = [];
  List<String> selectedMemberEmails = [];
  TextEditingController searchController = TextEditingController();
  bool showUserSelection = false;

  int totalCostPerPerson = 0;
  int totalCostAll = 0;

  // Add Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchCities();
    fetchAllUserEmails();
  }

  void fetchCities() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('cityRoutes').get();
    final origins = <String>{};
    final destinations = <String>{};

    for (var doc in snapshot.docs) {
      origins.add(doc['originCity']);
      destinations.add(doc['destinationCity']);
    }

    setState(() {
      originCities = origins.toList();
      destinationCities = destinations.toList();
    });
  }

  void fetchAllUserEmails() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      allUserEmails = snapshot.docs
          .map((doc) => doc.data()['email']?.toString() ?? '')
          .where((email) => email.isNotEmpty)
          .toList();
    });
  }

  // Add function to create notifications
  Future<void> createTripNotifications() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;
      
      // Get current user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      final currentUserEmail = userDoc.data()?['email'] ?? '';
      final currentUserName = userDoc.data()?['name'] ?? 'User';
      
      // Create a list of all users to notify (selected members + current user)
      List<String> allUsersToNotify = List.from(selectedMemberEmails);
      allUsersToNotify.add(currentUserEmail);
      
      // Create notification for each user
      for (String email in allUsersToNotify) {
        // Get user ID by email
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
            
        if (userQuery.docs.isNotEmpty) {
          final userId = userQuery.docs.first.id;
          
          // Create notification
          await FirebaseFirestore.instance
              .collection('notifications')
              .add({
            'userId': userId,
            'userEmail': email,
            'title': 'New Trip Created',
            'message': '$currentUserName has created a trip from $selectedOrigin to $selectedDestination',
            'type': 'trip_created',
            'tripDetails': {
              'origin': selectedOrigin,
              'destination': selectedDestination,
              'travelMode': travelMode,
              'hotelType': hotelType,
              'foodType': foodType,
              'numPersons': numPersons,
              'totalCost': totalCostAll,
            },
            'createdBy': currentUser.uid,
            'createdByEmail': currentUserEmail,
            'createdAt': FieldValue.serverTimestamp(),
            'isRead': false,
          });
        }
      }
      
      print('Notifications created successfully for ${allUsersToNotify.length} users');
    } catch (e) {
      print('Error creating notifications: $e');
    }
  }

  List<String> get filteredEmails {
    if (searchController.text.isEmpty) {
      return allUserEmails;
    }
    return allUserEmails.where((email) {
      return email.toLowerCase().contains(searchController.text.toLowerCase());
    }).toList();
  }

  void toggleUserSelection(String email) {
    setState(() {
      if (selectedMemberEmails.contains(email)) {
        selectedMemberEmails.remove(email);
      } else if (selectedMemberEmails.length < numPersons - 1) {
        selectedMemberEmails.add(email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'You can only select ${numPersons - 1} additional members')),
        );
      }
    });
  }

  void calculateCost() async {
    if (selectedOrigin == null || selectedDestination == null) return;

    final query = await FirebaseFirestore.instance
        .collection('cityRoutes')
        .where('originCity', isEqualTo: selectedOrigin)
        .where('destinationCity', isEqualTo: selectedDestination)
        .get();

    if (query.docs.isEmpty) {
      setState(() {
        totalCostPerPerson = 0;
        totalCostAll = 0;
      });
      return;
    }

    final data = query.docs.first.data();
    final travel = data['travelCost'][travelMode] ?? 0;
    final hotel = data['hotelCost'][hotelType] ?? 0;
    final food = data['foodCost'][foodType] ?? 0;

    final costPerPerson = travel + hotel + food;

    setState(() {
      totalCostPerPerson = costPerPerson;
      totalCostAll = costPerPerson * numPersons;
      showUserSelection = numPersons > 1;

      if (selectedMemberEmails.length > numPersons - 1) {
        selectedMemberEmails =
            selectedMemberEmails.sublist(0, numPersons - 1);
      }
    });
  }

  Widget dropdown(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 12), // ✅ margin top added
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.grey[900],
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        value: value,
        items: items
            .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: const TextStyle(color: Colors.white),
                )))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildUserSelectionPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          "Select Travel Members (${selectedMemberEmails.length}/${numPersons - 1})",
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Search users by email',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[850],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.white70),
                onPressed: () {
                  searchController.clear();
                  setState(() {});
                },
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: filteredEmails.isEmpty
              ? const Center(
                  child:
                      Text('No users found', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredEmails.length,
                  itemBuilder: (context, index) {
                    final email = filteredEmails[index];
                    final isSelected = selectedMemberEmails.contains(email);

                    return Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getAvatarColor(email),
                          foregroundColor: Colors.white,
                          child: Text(
                            email.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(email,
                            style: const TextStyle(color: Colors.white)),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                        onTap: () => toggleUserSelection(email),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 10),
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
  title: Text(
    'Customize Your Trip',
    style: GoogleFonts.quicksand(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    ),
  ),
  backgroundColor: Colors.black,
  elevation: 0,
  iconTheme: const IconThemeData(color: Colors.white),
  actionsIconTheme: const IconThemeData(color: Colors.white),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
   onPressed: () {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const TravelHomePage()),
  );
},

  ),
),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              dropdown("Origin City", selectedOrigin, originCities, (val) {
                setState(() {
                  selectedOrigin = val;
                  calculateCost();
                });
              }),
              dropdown("Destination City", selectedDestination, destinationCities,
                  (val) {
                setState(() {
                  selectedDestination = val;
                  calculateCost();
                });
              }),
              dropdown("Travel Mode", travelMode, ['air', 'train', 'road'], (val) {
                setState(() {
                  travelMode = val!;
                  calculateCost();
                });
              }),
              dropdown("Hotel Type", hotelType, ['low', 'medium', 'high'], (val) {
                setState(() {
                  hotelType = val!;
                  calculateCost();
                });
              }),
              dropdown("Food Type", foodType, ['low', 'medium', 'high'], (val) {
                setState(() {
                  foodType = val!;
                  calculateCost();
                });
              }),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(top: 12), // ✅ margin top
                child: TextFormField(
                  initialValue: numPersons.toString(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Number of Persons',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      numPersons = int.tryParse(val) ?? 1;
                      if (numPersons < 1) numPersons = 1;
                      calculateCost();
                    });
                  },
                ),
              ),
              if (showUserSelection) buildUserSelectionPanel(),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Cost per person:",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  Text(
                    "PKR $totalCostPerPerson",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent),
                  ),
                  const SizedBox(height: 10),
                  Text("Total cost for $numPersons person(s):",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  Text(
                    "PKR $totalCostAll",
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  if (selectedOrigin != null && selectedDestination != null) {
                    if (numPersons > 1 &&
                        selectedMemberEmails.length != numPersons - 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Please select ${numPersons - 1} members')),
                      );
                      return;
                    }

                    // Create notifications before navigating
                    await createTripNotifications();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripBookingForm(
                          origin: selectedOrigin!,
                          destination: selectedDestination!,
                          travelMode: travelMode,
                          hotelType: hotelType,
                          foodType: foodType,
                          totalCost: totalCostAll,
                          memberEmails: selectedMemberEmails,
                          numPersons: numPersons,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Please select both origin and destination')),
                    );
                  }
                },
                child: const Text("Done",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}