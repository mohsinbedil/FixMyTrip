// File: lib/User/widgets/BottomNavBar.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavbar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = 60; // height of the nav bar

    final primaryColor = Theme.of(context).colorScheme.primary;
    // final secondaryColor = Theme.of(context).colorScheme.secondary;
    final backgroundColor = Colors.black;

    return SizedBox(
      height: height + 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Curved background
          CustomPaint(
            size: Size(size.width, height + 20),
            painter: BottomNavCurvePainter(backgroundColor: backgroundColor),
          ),

          // Floating action button in the middle
          Positioned(
            top: -28, // half of FAB height
            left: size.width / 2 - 28,
            child: FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () {
                // define FAB action
              },
              child: const Icon(CupertinoIcons.wind, color: Colors.black),
              elevation: 0,
            ),
          ),

          // Navigation icons
          SizedBox(
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarIcon(
                  text: "Home",
                  icon: Icons.home,
                  selected: widget.currentIndex == 0,
                  onPressed: () => widget.onTap(0),
                  defaultColor: Colors.grey[500]!,
                  selectedColor: Colors.white,
                ),
                NavBarIcon(
                  text: "Trips",
                  icon: Icons.card_travel,
                  selected: widget.currentIndex == 1,
                  onPressed: () => widget.onTap(1),
                  defaultColor: Colors.grey[500]!,
                  selectedColor: Colors.white,
                ),
                const SizedBox(width: 56), // space for FAB
                NavBarIcon(
                  text: "Map",
                  icon: Icons.map,
                  selected: widget.currentIndex == 2,
                  onPressed: () => widget.onTap(2),
                  defaultColor: Colors.grey[500]!,
                  selectedColor: Colors.white,
                ),
                NavBarIcon(
                  text: "Notify",
                  icon: Icons.notifications,
                  selected: widget.currentIndex == 3,
                  onPressed: () => widget.onTap(3),
                  defaultColor: Colors.grey[500]!,
                  selectedColor: Colors.white,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class BottomNavCurvePainter extends CustomPainter {
  final Color backgroundColor;
  final double insetRadius;

  BottomNavCurvePainter({this.backgroundColor = Colors.black, this.insetRadius = 38});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    Path path = Path()..moveTo(0, 12);

    double insetCurveBeg = size.width / 2 - insetRadius;
    double insetCurveEnd = size.width / 2 + insetRadius;
    double transitionWidth = size.width * .05;

    path.quadraticBezierTo(size.width * 0.20, 0,
        insetCurveBeg - transitionWidth, 0);
    path.quadraticBezierTo(insetCurveBeg, 0, insetCurveBeg, insetRadius / 2);
    path.arcToPoint(Offset(insetCurveEnd, insetRadius / 2),
        radius: const Radius.circular(10.0), clockwise: false);
    path.quadraticBezierTo(insetCurveEnd, 0, insetCurveEnd + transitionWidth, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 12);
    path.lineTo(size.width, size.height + 56);
    path.lineTo(0, size.height + 56);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

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
                fontWeight: selected ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
