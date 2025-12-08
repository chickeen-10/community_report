import 'package:community_report/screens/admin/admin_update_report.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:community_report/models/report_model.dart';
import 'package:community_report/db/database_report_helper.dart';
import '../auth/login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late Future<List<ReportModel>> _reportsFuture;
  String selectedCategory = "All";
  String selectedStatus = "All"; // Track selected status filter

  final Map<String, Color> categoryColors = {
    "Infrastructure": Colors.orange,
    "Safety": Colors.red,
    "Environment": Colors.green,
    "Public Space": Colors.blue,
    "Traffic": Colors.amber,
    "Other": Colors.grey,
  };

  final Map<String, IconData> categoryIcons = {
    "Infrastructure": Icons.home_repair_service,
    "Safety": Icons.security,
    "Environment": Icons.eco,
    "Public Space": Icons.park,
    "Traffic": Icons.traffic,
    "Other": Icons.category,
  };

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    setState(() {
      _reportsFuture = ReportDBHelper.instance.getAllReports();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "In Progress":
        return Colors.blue;
      case "Resolve":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFilterChip(String category) {
    final isSelected = selectedCategory == category;
    Color color = category == "All"
        ? Colors.black54
        : categoryColors[category] ?? Colors.grey;
    IconData? icon = category == "All" ? Icons.list : categoryIcons[category];

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = category;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                category,
                style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - All Reports"),
        actions: [
          // STATUS FILTER BUTTON
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                selectedStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "All",
                child: Text("All Status"),
              ),
              const PopupMenuItem(
                value: "Pending",
                child: Text("Pending"),
              ),
              const PopupMenuItem(
                value: "In Progress",
                child: Text("In Progress"),
              ),
              const PopupMenuItem(
                value: "Resolve",
                child: Text("Resolve"),
              ),
            ],
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.red,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // FILTER CHIPS BAR
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildFilterChip("All"),
                _buildFilterChip("Infrastructure"),
                _buildFilterChip("Safety"),
                _buildFilterChip("Environment"),
                _buildFilterChip("Public Space"),
                _buildFilterChip("Traffic"),
                _buildFilterChip("Other"),
              ],
            ),
          ),

          // REPORTS LIST
          Expanded(
            child: FutureBuilder<List<ReportModel>>(
              future: _reportsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Apply both category and status filters
                final reports = snapshot.data!
                    .where((r) =>
                        (selectedCategory == "All" ||
                            r.category == selectedCategory) &&
                        (selectedStatus == "All" || r.status == selectedStatus))
                    .toList();

                if (reports.isEmpty) {
                  return const Center(
                    child: Text(
                      "No reports found",
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final r = reports[index];
                    final date = r.date != null
                        ? DateFormat("MMM dd, yyyy").format(r.date!)
                        : "";
                    final category =
                        r.category.isNotEmpty ? r.category : "Other";
                    final categoryColor =
                        categoryColors[category] ?? Colors.grey;
                    final categoryIcon =
                        categoryIcons[category] ?? Icons.category;

                    return GestureDetector(
                      onTap: () async {
                        final updated = await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => AdminUpdateSheet(report: r),
                        );

                        if (updated == true) _loadReports();
                      },
                      child: Card(
                        elevation: 8,
                        shadowColor: Colors.grey.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24)),
                              child:
                                  r.imagePath != null && r.imagePath!.isNotEmpty
                                      ? Image.file(
                                          File(r.imagePath!),
                                          height: 220,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 220,
                                          width: double.infinity,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 80,
                                            color: Colors.white70,
                                          ),
                                        ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Category Tag with Icon
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(categoryIcon,
                                            color: categoryColor, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          category,
                                          style: TextStyle(
                                              color: categoryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    r.title,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    r.description,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        height: 1.4),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        "$date${(r.user != null && r.user!.isNotEmpty) ? ' by ${r.user}' : ''}",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _statusColor(r.status)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        r.status,
                                        style: TextStyle(
                                            color: _statusColor(r.status),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
