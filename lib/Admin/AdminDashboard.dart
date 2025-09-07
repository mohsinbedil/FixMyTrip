import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import './Accepted_Trips.dart';
import './UserDetails.dart';
import './AddTrip.dart';
import './AddCities.dart';
import './AddCustomTripsDetails.dart';
import './CustomTripBookingOrder.dart';
import './Trip_List.dart';
import './AdminChatList.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2D),
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF2C2C3C),
        elevation: 1,
        foregroundColor: Colors.white,
      ),
      drawer: const Sidebar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            TitleText(),
            SizedBox(height: 16),
            ParallaxEffect(),
            SizedBox(height: 16),
            DashboardTabs(),
          ],
        ),
      ),
    );
  }
}

/// Sidebar / Drawer
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF2C2C3C),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(height: 12),
                _sidebarTile(context, Icons.people, "Manage Users", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const UserDetails()));
                }),
                const SizedBox(height: 12),
                _sidebarTile(context, Icons.add_location_alt, "Add Trip", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AddTripPage()));
                }),
                const SizedBox(height: 12),
                _sidebarTile(context, Icons.location_city, "Add Cities", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AddCities()));
                }),
                const SizedBox(height: 12),
                _sidebarTile(context, Icons.explore, "Custom Trips", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AddCustomTripsDetails()));
                }),
                const SizedBox(height: 12),
                _sidebarTile(context, Icons.shopping_bag, "Custom Orders", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CutommTripBookingOrder()));
                }),
                const SizedBox(height: 12),
                _sidebarTile(context, Icons.list_alt, "Trip List", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminTripsPage()));
                }),
                const SizedBox(height: 12),
                _sidebarTile(context, Icons.check_circle, "Accepted Trips", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AcceptedTripsPage()));
                }),
                const SizedBox(height: 12),
                _sidebarTile(context, Icons.settings, "Settings", () {}),
              ],
            ),
            _sidebarTile(context, Icons.logout, "Logout", () {
              // TODO: Implement logout logic
            }),
          ],
        ),
      ),
    );
  }

  Widget _sidebarTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFc1ff72)),
      title: Text(title, style: GoogleFonts.raleway(color: Colors.white)),
      onTap: () {
        Navigator.pop(context); // close drawer
        onTap();
      },
    );
  }
}

/// Title section
class TitleText extends StatelessWidget {
  const TitleText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome to Admin Panel",
          style: GoogleFonts.raleway(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Stay on top of your tasks, monitor progress, and track status.",
          style: GoogleFonts.raleway(
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

/// Dashboard tabs (horizontal)
class DashboardTabs extends StatelessWidget {
  const DashboardTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {"title": "Manage Users", "icon": Icons.people, "page": const UserDetails()},
      {"title": "Add Trip", "icon": Icons.add_location_alt, "page": AddTripPage()},
      {"title": "Add Cities", "icon": Icons.location_city, "page": const AddCities()},
      {"title": "Trip List", "icon": Icons.list_alt, "page": const AdminTripsPage()},
      {"title": "Accepted Trips", "icon": Icons.check_circle, "page": const AcceptedTripsPage()},
      {"title": "Custom Trips Request", "icon": Icons.people, "page": const CutommTripBookingOrder()},
      {"title": "Make Custom Trip", "icon": Icons.add, "page": const AddCustomTripsDetails()},
      {"title": "Chat Support", "icon": Icons.message, "page": const AdminChatScreen()},
    ];

    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: tabs.map((tab) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => tab["page"] as Widget),
                );
              },
              child: Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C3C),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tab["icon"] as IconData, color: const Color(0xFFc1ff72), size: 28),
                    const SizedBox(height: 8),
                    Text(
                      tab["title"].toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.raleway(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Parallax Effect Widget
/// Centered Parallax Effect Widget
class ParallaxEffect extends StatefulWidget {
  const ParallaxEffect({super.key});

  @override
  State<ParallaxEffect> createState() => _ParallaxEffectState();
}

class _ParallaxEffectState extends State<ParallaxEffect> {
  final PageController pageController = PageController(viewportFraction: 0.85);
  double pageOffSet = 0;

  final List<Map<String, String>> parallaxItems = const [
    {
      "image":
          "https://images.pexels.com/photos/1271619/pexels-photo-1271619.jpeg",
      "title": "Mountain"
    },
    {
      "image":
          "https://images.unsplash.com/photo-1501785888041-af3ef285b470?ixlib=rb-1.2.1&auto=format&fit=crop&w=1400&q=80",
      "title": "Beach"
    },
    {
      "image":
          "https://images.unsplash.com/photo-1517821365203-3e4c4b403a53?ixlib=rb-1.2.1&auto=format&fit=crop&w=1400&q=80",
      "title": "Forest"
    },
    {
      "image":
          "https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-1.2.1&auto=format&fit=crop&w=1400&q=80",
      "title": "Desert"
    },
    {
      "image":
          "https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-1.2.1&auto=format&fit=crop&w=1400&q=80",
      "title": "Cityscape"
    },
  ];

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        pageOffSet = pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: PageView.builder(
        controller: pageController,
        itemCount: parallaxItems.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = parallaxItems[index];
          double scale = (1 - (pageOffSet - index).abs() * 0.2).clamp(0.8, 1.0);

          return Center(
            child: Transform.scale(
              scale: scale,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Image.network(
                      item["image"]!,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.75,
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item["title"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 3,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

