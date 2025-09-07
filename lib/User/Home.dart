import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fix_my_trip/User/Login.dart';
import 'package:fix_my_trip/User/Manu.dart';
import 'package:fix_my_trip/User/Notifications.dart';
import 'package:fix_my_trip/User/demo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './AllTripsPage.dart';
import './Map.dart';
import './CustomTrip.dart';
import './CustomTripStatus.dart';
import './TravelHomePage.dart' hide ScrollCardsUI;
import './ChatScreen.dart';


class HomePage extends StatefulWidget {
  final String email;

  const HomePage({super.key, required this.email});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _username;
  bool _isLoading = true;
  int _currentIndex = 0;

  final TextEditingController searchController = TextEditingController();
  List<String> allCities = [];
  List<String> filteredCities = [];
  bool isCitiesLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsername();
    fetchCities();
  }

  Future<void> fetchUsername() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: widget.email)
              .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          _username = query.docs.first.data()['fullName'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _username = "User";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _username = "Error loading user";
        _isLoading = false;
      });
    }
  }

  Future<void> fetchCities() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('cities')
              .orderBy('createdAt', descending: true)
              .get();

      final cities = snapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        allCities = cities;
        filteredCities = cities;
        isCitiesLoading = false;
      });
    } catch (e) {
      print('Error fetching cities: $e');
      setState(() {
        isCitiesLoading = false;
      });
    }
  }

  void filterCities(String query) {
    final results =
        allCities
            .where((city) => city.toLowerCase().contains(query.toLowerCase()))
            .toList();

    setState(() {
      filteredCities = results;
    });
  }

  final List<Widget> _pages = [
    const TravelHomePage(),
    const AllTripsPage(),
    Map(),
    CustomTrip(),
    CustomTripStatus(),
    const Center(child: Text("Profile Page")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 0, 0, 0),
              Color.fromARGB(255, 0, 0, 0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // App title on the left
                    Text(
                      "FIX MY TRIP",
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 28,
                      ),
                    ),

                    // Icons on the right
                    Row(
                      children: [
                        // Map icon
                     IconButton(
                          icon: const Icon(
                            Icons.message,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserChatScreen(),
                              ),
                            );
                          },
                        ),
                        // Profile icon
                        IconButton(
                          icon: const Icon(
                            Icons.account_circle,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MenuScreen(),
                              ),
                            );
                          },
                        ),

                        // Logout icon
                        IconButton(
                          icon: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: filterCities,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search cities...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Show filtered cities list OR selected page
              Expanded(
                child:
                    searchController.text.isNotEmpty
                        ? (isCitiesLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : filteredCities.isEmpty
                            ? const Center(
                              child: Text(
                                'No cities found',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                            : Container(
                              color: Colors.black87, // dark background
                              child: ListView.builder(
                                itemCount: filteredCities.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: const Icon(
                                      Icons.location_city,
                                      color: Color(0xFFC1FF72),
                                    ),
                                    title: Text(
                                      filteredCities[index],
                                      style: const TextStyle(
                                        color: Color(0xFF0097b2),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ))
                        : Container(
                          margin: const EdgeInsets.only(top: 5),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: _pages[_currentIndex],
                        ),
              ),
            ],
          ),
        ),
      ),

      // Updated Curved Bottom Navigation
      bottomNavigationBar: SizedBox(
        height: 70,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Curved background with gradient border
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 70),
              painter: BottomNavCurvePainter(
                backgroundColor: const Color.fromARGB(255, 37, 37, 37),
              ),
            ),

            // Center FAB
            Positioned(
              top: -25,
              left: MediaQuery.of(context).size.width / 2 - 25,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFFC1FF72),
                onPressed: () => setState(() => _currentIndex = 2),
                child: const Icon(Icons.map, color: Colors.black),
                elevation: 0,
                mini: true,
              ),
            ),

            // Navigation icons
            SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavBarIcon(
                    text: "Home",
                    icon: Icons.home,
                    selected: _currentIndex == 0,
                    onPressed: () => setState(() => _currentIndex = 0),
                    selectedColor: const Color(0xFFC1FF72),
                    defaultColor: Colors.grey[500]!,
                  ),
                  NavBarIcon(
                    text: "Trips",
                    icon: Icons.card_travel,
                    selected: _currentIndex == 1,
                    onPressed: () => setState(() => _currentIndex = 1),
                    selectedColor: const Color(0xFFC1FF72),
                    defaultColor: Colors.grey[500]!,
                  ),
                  const SizedBox(width: 50), // space for FAB
                  NavBarIcon(
                    text: "Custom",
                    icon: Icons.edit_location_alt,
                    selected: _currentIndex == 3,
                    onPressed: () => setState(() => _currentIndex = 3),
                    selectedColor: const Color(0xFFC1FF72),
                    defaultColor: Colors.grey[500]!,
                  ),
                  NavBarIcon(
                    text: "Status",
                    icon: Icons.notifications_active,
                    selected: _currentIndex == 4,
                    onPressed: () => setState(() => _currentIndex = 4),
                    selectedColor: const Color(0xFFC1FF72),
                    defaultColor: Colors.grey[500]!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for curved bottom nav with gradient border
class BottomNavCurvePainter extends CustomPainter {
  final Color backgroundColor;
  final double insetRadius;

  BottomNavCurvePainter({
    this.backgroundColor = Colors.black,
    this.insetRadius = 35,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

    Path path = Path()..moveTo(0, 12);

    double insetCurveBeg = size.width / 2 - insetRadius;
    double insetCurveEnd = size.width / 2 + insetRadius;
    double transitionWidth = size.width * .05;

    path.quadraticBezierTo(
      size.width * 0.2,
      0,
      insetCurveBeg - transitionWidth,
      0,
    );
    path.quadraticBezierTo(insetCurveBeg, 0, insetCurveBeg, insetRadius / 2);
    path.arcToPoint(
      Offset(insetCurveEnd, insetRadius / 2),
      radius: const Radius.circular(10.0),
      clockwise: false,
    );
    path.quadraticBezierTo(
      insetCurveEnd,
      0,
      insetCurveEnd + transitionWidth,
      0,
    );
    path.quadraticBezierTo(size.width * 0.8, 0, size.width, 12);
    path.lineTo(size.width, size.height + 20);
    path.lineTo(0, size.height + 20);
    path.close();

    canvas.drawPath(path, paint);

    Paint borderPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              Color.fromARGB(255, 0, 0, 0),
              Color.fromARGB(255, 0, 0, 0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// NavBarIcon Widget
class NavBarIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final Function() onPressed;
  final Color defaultColor;
  final Color selectedColor;

  const NavBarIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.selected,
    required this.onPressed,
    this.defaultColor = Colors.grey,
    this.selectedColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 25, color: selected ? selectedColor : defaultColor),
          const SizedBox(height: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: selected ? selectedColor : defaultColor,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
