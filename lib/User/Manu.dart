import 'package:fix_my_trip/User/ConfirmTrip.dart';
import 'package:fix_my_trip/User/Profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 🔥 dark theme
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Menu Options',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuOption(
            context,
            icon: Icons.person,
            title: 'Profile',
            onTap: () => _navigateTo(context, const Profile()),
          ),
          _buildMenuOption(
            context,
            icon: Icons.money,
            title: 'Confirmed Trips',
            onTap: () => _navigateTo(context, ConfirmedTripsScreen()),
          ),
          // Future options:
          // _buildMenuOption(context, icon: Icons.settings, title: 'Settings', onTap: () {}),
          // _buildMenuOption(context, icon: Icons.notifications, title: 'Notifications', onTap: () {}),
          // _buildMenuOption(context, icon: Icons.help, title: 'Help & Support', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E1E), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
          // 💚 green glow effect
          BoxShadow(
            color: const Color(0xFFC1FF72).withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFC1FF72), size: 28),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
              // TODO: Add logout logic
            },
            child: Text('Logout', style: GoogleFonts.poppins(color: const Color(0xFFC1FF72))),
          ),
        ],
      ),
    );
  }
}
