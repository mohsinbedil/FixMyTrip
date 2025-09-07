import 'package:fix_my_trip/User/AllTripsPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';

class TravelHomePage extends StatefulWidget {
  const TravelHomePage({super.key});

  @override
  State<TravelHomePage> createState() => _TravelHomePageState();
}

class _TravelHomePageState extends State<TravelHomePage> {
  int _currentCarouselIndex = 0;

  // Carousel Items for Delicious Treats
  final List<ScrollItem> carouselItems = [
    ScrollItem(
      imageUrl: "https://images.unsplash.com/photo-1501785888041-af3ef285b470",
      title: "Chinese Samosa",
      description: "Delicious crispy samosas served hot.",
    ),
    ScrollItem(
      imageUrl: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
      title: "Sunny Beaches",
      description: "Relax and feel the calm waves by the golden sand.",
    ),
    ScrollItem(
      imageUrl: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
      title: "Green Forests",
      description: "Breathe the freshness of nature's green wonders.",
    ),
    ScrollItem(
      imageUrl: "https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0",
      title: "Golden Deserts",
      description: "Witness the endless dunes glowing under the sun.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Banner
              Stack(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  const Positioned(
                    bottom: 30,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find Peace in Every Journey.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Welcome to Fix My Trip — your ultimate travel companion.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        Text(
                          'Fix My Trip is here to turn your travel dreams into reality.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Section 1: Trending Picks
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Trending Picks",
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 24),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = trendingPicks[index];
                    return LandscapeCard(item: item);
                  },
                  separatorBuilder: (context, index) => const SizedBox(width: 15),
                  itemCount: trendingPicks.length,
                ),
              ),

              const SizedBox(height: 30),

              // Section 2: Popular Destinations
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Popular Destinations",
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 15),
              Column(
                children: popularDestinations
                    .map((dest) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          child: DestinationCard(item: dest),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 30),

              // Section 3: Top Activities
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Top Activities",
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 24),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final activity = topActivities[index];
                    return ActivityCard(item: activity);
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 15),
                  itemCount: topActivities.length,
                ),
              ),

              const SizedBox(height: 30),

              // Section 4: Travel Tips / Blogs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Travel Tips & Blogs",
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 15),
              Column(
                children: travelTips
                    .map((tip) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          child: TravelTipCard(item: tip),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 30),

              // ===================== Section 5: Delicious Treats Carousel =====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Delicious Treats",
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Explore our menu",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Carousel Indicators
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: carouselItems.map((item) {
                    int index = carouselItems.indexOf(item);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: _currentCarouselIndex == index ? 30 : 10,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: _currentCarouselIndex == index
                            ? const Color(0xFFc1ff72)
                            : Colors.grey,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Carousel Slider
              CarouselSlider(
                items: carouselItems.map((item) {
                  return GestureDetector(
                    onTap: () {},
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.description,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AllTripsPage()),
    );
  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFc1ff72),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    fixedSize: const Size(double.maxFinite, 40),
                                  ),
                                  child: const Text(
                                    "Explore",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 400,
                  viewportFraction: 0.75,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentCarouselIndex = index;
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== Data Models =====================
class ScrollItem {
  final String imageUrl;
  final String title;
  final String description;

  ScrollItem(
      {required this.imageUrl, required this.title, required this.description});
}

// Section 1: Trending Picks
List<ScrollItem> trendingPicks = [
  ScrollItem(
      imageUrl:
          'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=800&q=80',
      title: 'Mountain View',
      description: 'Breathtaking mountain view'),
  ScrollItem(
      imageUrl:
          'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=800&q=80',
      title: 'City Lights',
      description: 'Explore the city at night'),
  ScrollItem(
      imageUrl:
          'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80',
      title: 'Sunny Beach',
      description: 'Relax at the sunny beach'),
];

// Section 2: Popular Destinations
List<ScrollItem> popularDestinations = [
  ScrollItem(
      imageUrl:
          'https://images.unsplash.com/photo-1559181567-c3190ca9959b?auto=format&fit=crop&w=800&q=80',
      title: 'Malam Jabba',
      description: 'Blend of tradition & technology'),
  ScrollItem(
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
      title: 'Skardu',
      description: 'Tropical paradise'),
  ScrollItem(
      imageUrl:
          'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?auto=format&fit=crop&w=800&q=80',
      title: 'Naran Kaghan',
      description: 'City of lights and romance'),
];

// Section 3: Top Activities
List<ScrollItem> topActivities = [
  ScrollItem(
      imageUrl:
          'https://images.pexels.com/photos/1058958/pexels-photo-1058958.jpeg',
      title: 'Hiking',
      description: 'Adventure in the mountains'),
  ScrollItem(
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
      title: 'Scuba Diving',
      description: 'Explore the underwater world'),
  ScrollItem(
      imageUrl:
          'https://images.unsplash.com/photo-1473187983305-f615310e7daa',
      title: 'City Tour',
      description: 'Discover hidden city gems'),
];

// Section 4: Travel Tips / Blogs
List<ScrollItem> travelTips = [
  ScrollItem(
      imageUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
      title: 'Packing Tips',
      description: 'How to pack efficiently for long trips'),
  ScrollItem(
      imageUrl:
          'https://images.unsplash.com/photo-1472214103451-9374bd1c798e',
      title: 'Budget Travel',
      description: 'Travel without breaking the bank'),
  ScrollItem(
      imageUrl:
          'https://images.unsplash.com/photo-1501426026826-31c667bdf23d',
      title: 'Travel Safety',
      description: 'Stay safe while exploring new destinations'),
];

// ===================== Card Widgets =====================

// Horizontal Card
class LandscapeCard extends StatelessWidget {
  final ScrollItem item;
  const LandscapeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(item.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            left: 15,
            bottom: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  item.description,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Vertical Destination Card
class DestinationCard extends StatelessWidget {
  final ScrollItem item;
  const DestinationCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(item.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                )),
          ),
          Positioned(
            left: 15,
            bottom: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  item.description,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Horizontal Activity Card
class ActivityCard extends StatelessWidget {
  final ScrollItem item;
  const ActivityCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(item.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                )),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Text(
              item.title,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// Vertical Travel Tip Card
class TravelTipCard extends StatelessWidget {
  final ScrollItem item;
  const TravelTipCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(item.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                )),
          ),
          Positioned(
            left: 15,
            bottom: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  item.description,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
