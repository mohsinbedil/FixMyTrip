import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          /// scrolling background images
          const Positioned(
            top: -10,
            left: -160,
            child: Row(
              children: [
                ScrollingImages(startingIndex: 0),
                ScrollingImages(startingIndex: 1),
                ScrollingImages(startingIndex: 2),
              ],
            ),
          ),

          /// App Title
          Positioned(
            top: 60,
            child: Text(
              "Fix My Trip",
              textScaleFactor: 2.2,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: const Color(0xFFC1FF72),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),

          /// bottom container with text + button
          Positioned(
            bottom: 0,
            child: Container(
              height: h * 0.55,
              width: w,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    "Plan. Book. Travel.",
                    textScaleFactor: 2.3,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Your ultimate trip planner — flights, hotels, food,\n"
                    "and everything in between, made simple.",
                    textScaleFactor: 1.2,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 50),

                  /// Signup button
                  InkWell(
                    onTap: () {
                      // Navigate to login/signup
                    },
                    child: Container(
                      height: 55,
                      width: w * 0.8,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC1FF72), Color(0xFF9EE052)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC1FF72).withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Get Started",
                          textScaleFactor: 1.3,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ScrollingImages extends StatefulWidget {
  final int startingIndex;

  const ScrollingImages({
    Key? key,
    required this.startingIndex,
  }) : super(key: key);

  @override
  State<ScrollingImages> createState() => _ScrollingImagesState();
}

class _ScrollingImagesState extends State<ScrollingImages> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.offset ==
          _scrollController.position.minScrollExtent) {
        _autoScrollForward();
      } else if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        _autoScrollbackward();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScrollForward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _autoScrollForward() {
    final currentPosition = _scrollController.offset;
    final endPosition = _scrollController.position.maxScrollExtent;
    scheduleMicrotask(() {
      _scrollController.animateTo(
        currentPosition == endPosition ? 0 : endPosition,
        duration: Duration(seconds: 20 + widget.startingIndex + 2),
        curve: Curves.linear,
      );
    });
  }

  _autoScrollbackward() {
    final currentPosition = _scrollController.offset;
    final endPosition = _scrollController.position.minScrollExtent;
    scheduleMicrotask(() {
      _scrollController.animateTo(
        currentPosition == endPosition ? 0 : endPosition,
        duration: Duration(seconds: 20 + widget.startingIndex + 2),
        curve: Curves.linear,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Transform.rotate(
      angle: 1.96 * pi,
      child: SizedBox(
        height: h * 0.6,
        width: w * 0.6,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              height: h * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Landscape travel images
List<String> images = [
  "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1920&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=1920&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1493558103817-58b2924bce98?q=80&w=1920&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1526772662000-3f88f10405ff?q=80&w=1920&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=1920&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1473625247510-8ceb1760943f?q=80&w=1920&auto=format&fit=crop",
];
