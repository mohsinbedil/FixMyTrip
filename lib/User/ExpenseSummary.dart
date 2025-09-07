import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_my_trip/User/AddExpense.dart';

class TripExpenseSummaryScreen extends StatefulWidget {
  final String tripId;

  const TripExpenseSummaryScreen({super.key, required this.tripId});

  @override
  _TripExpenseSummaryScreenState createState() => _TripExpenseSummaryScreenState();
}

class _TripExpenseSummaryScreenState extends State<TripExpenseSummaryScreen> {
  late Future<Map<String, dynamic>> _tripData;
  late Future<QuerySnapshot> _expensesData;
  List<String> _memberEmails = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _tripData = FirebaseFirestore.instance
        .collection('userBookings')
        .doc(widget.tripId)
        .get()
        .then((snapshot) {
      final data = snapshot.data()!;
      _memberEmails = List<String>.from(data['memberEmails'] ?? []);
      return data;
    });

    _expensesData = FirebaseFirestore.instance
        .collection('userBookings')
        .doc(widget.tripId)
        .collection('expenses')
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Expense Summary",
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpenseScreen(tripId: widget.tripId),
            ),
          ).then((_) => _loadData());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder(
        future: Future.wait([_tripData, _expensesData]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final tripData = snapshot.data![0] as Map<String, dynamic>;
          final expenses = snapshot.data![1] as QuerySnapshot;

          // Calculate total expenses
          double totalExpenses = 0;
          for (var doc in expenses.docs) {
            totalExpenses += (doc.data() as Map<String, dynamic>)['amount'] ?? 0;
          }

          // Calculate per person amount (totalCost + totalExpenses) / memberCount
          final memberCount = _memberEmails.length;
          final totalAmount = (tripData['totalCost'] ?? 0) + totalExpenses;
          final perPersonAmount = memberCount > 0 ? totalAmount / memberCount : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Budget Card
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade900, Colors.black],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Budget:",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "\$${tripData['totalCost']?.toStringAsFixed(2) ?? '0.00'}",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Expenses:",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "\$${totalExpenses.toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Amount:",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "\$${(double.parse(tripData['totalCost']?.toString() ?? '0') + totalExpenses).toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Per Person Share Card
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade900, Colors.black],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Per Person Share:",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "\$${perPersonAmount.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${memberCount} members",
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Members List
                Text(
                  "Members",
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _memberEmails.length,
                  itemBuilder: (context, index) {
                    final email = _memberEmails[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            color: Colors.blueAccent,
                          ),
                        ),
                        title: Text(
                          email,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        trailing: Text(
                          "\$${perPersonAmount.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Expenses List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Expenses",
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to full expenses list
                      },
                      child: Text(
                        "View All",
                        style: GoogleFonts.poppins(
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...expenses.docs.take(3).map((doc) {
                  final expense = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent.withOpacity(0.2),
                        child: Icon(
                          _getCategoryIcon(expense['category']),
                          color: Colors.blueAccent,
                        ),
                      ),
                      title: Text(
                        expense['category'] ?? 'Expense',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      subtitle: Text(
                        expense['description'] ?? '',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                      trailing: Text(
                        "\$${expense['amount']?.toStringAsFixed(2) ?? '0.00'}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'accommodation':
        return Icons.hotel;
      case 'activity':
        return Icons.attractions;
      default:
        return Icons.receipt;
    }
  }
}