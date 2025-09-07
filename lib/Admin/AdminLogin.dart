import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import './AdminDashboard.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginAdmin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin login successful!')),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
      } on FirebaseAuthException catch (e) {
        String message = 'Login failed';
        if (e.code == 'user-not-found') {
          message = 'No admin found with this email';
        } else if (e.code == 'wrong-password') {
          message = 'Incorrect password';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(21, 23, 27, 1),
      body: Center(
        child: Container(
          width: 850,
          height: 500,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.58),
                blurRadius: 10,
                offset: const Offset(12, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              /// LEFT SIDE (Branding / Info)
              Expanded(
                flex: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(113, 85, 249, 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.code,
                              color: Colors.white, size: 28),
                          const SizedBox(width: 15),
                          Text("Admin Portal",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Secure Admin Access",
                        style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              /// RIGHT SIDE (Login Form)
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(22, 24, 28, 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// MESSAGE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Admin Login",
                                style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                            const SizedBox(height: 10),
                            Text(
                              "Enter your credentials to access the dashboard securely.",
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  height: 1.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        /// EMAIL FIELD
                        _buildInputField(
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          hint: "Email",
                        ),
                        const SizedBox(height: 15),

                        /// PASSWORD FIELD
                        _buildInputField(
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          hint: "Password",
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),

                        /// LOGIN BUTTON
                        SizedBox(
                          width: 285,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(94, 64, 240, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onPressed: _isLoading ? null : _loginAdmin,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  )
                                : const Text("Login",
                                    style: TextStyle(color: Colors.white)),
                          ),
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
  }

  /// Input field builder
  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      width: 285,
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.58),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: isPassword,
              validator: (value) =>
                  value == null || value.isEmpty ? "Enter $hint" : null,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
