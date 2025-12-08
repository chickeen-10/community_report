import 'package:flutter/material.dart';
import 'package:community_report/db/database_report_helper.dart';
import 'package:community_report/models/report_model.dart';
import 'report_detail_screen.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class HomeTab extends StatefulWidget {
  final String loggedInUser;
  final String loggedInRole;

  const HomeTab(
      {super.key, required this.loggedInUser, required this.loggedInRole});

  @override
  State<HomeTab> createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  late Future<List<ReportModel>> _reportsFuture;
  String selectedCategory = "All";

  final Map<String, Color> categoryColors = {
    "Infrastructure": Colors.orange,
    "Safety": Colors.red,
    "Environment": Colors.green,
    "Public Space": Colors.blue,
    "Traffic": Colors.amber,
    "Other": Colors.grey,
  };

  final Map<String, IconData> categoryIcons = {
    "Infrastructure": Icons.apartment,
    "Safety": Icons.warning,
    "Environment": Icons.nature,
    "Public Space": Icons.park,
    "Traffic": Icons.traffic,
    "Other": Icons.category,
  };

  @override
  void initState() {
    super.initState();
    _refreshReports();
  }

  void refreshReports() => _refreshReports();

  void _refreshReports() {
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
    return Column(
      children: [
        // FILTER BAR
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

              // Filter reports
              final reports = snapshot.data!
                  .where((r) =>
                      selectedCategory == "All" ||
                      r.category == selectedCategory)
                  .toList();

              if (reports.isEmpty) {
                return const Center(
                  child: Text(
                    "No reports yet",
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
                  final categoryColor =
                      categoryColors[r.category] ?? Colors.grey;

                  return GestureDetector(
                    onTap: () async {
                      final deleted = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportDetailScreen(
                            report: r,
                            currentUserName:
                                widget.loggedInUser, // pass username here
                            currentRole: widget.loggedInRole,
                          ),
                        ),
                      );
                      if (deleted == true) _refreshReports();
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
                              top: Radius.circular(24),
                            ),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    r.category,
                                    style: TextStyle(
                                        color: categoryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
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
                                          fontSize: 14, color: Colors.black54),
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
    );
  }
}
