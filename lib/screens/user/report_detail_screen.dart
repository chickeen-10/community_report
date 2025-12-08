import 'package:community_report/models/report_model.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:community_report/db/database_report_helper.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;
  final String currentUserName; // username
  final String currentRole; // "admin" or "user"

  const ReportDetailScreen({
    super.key,
    required this.report,
    required this.currentUserName,
    required this.currentRole,
  });

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

  Future<void> _deleteReport(BuildContext context) async {
    final canDelete = currentRole.toLowerCase() == "admin" ||
        (report.user != null &&
            currentUserName.trim().toLowerCase() ==
                report.user!.trim().toLowerCase());

    if (!canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You do not have permission to delete this report.")),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Report"),
        content: const Text(
            "Are you sure you want to delete this report permanently?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ReportDBHelper.instance.deleteReport(report.id!);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report deleted successfully")));
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = report.date != null
        ? DateFormat("MMM dd, yyyy").format(report.date!)
        : "";

    final Map<String, Color> categoryColors = {
      "Infrastructure": Colors.orange,
      "Safety": Colors.red,
      "Environment": Colors.green,
      "Public Space": Colors.blue,
      "Traffic": Colors.amber,
      "Other": Colors.grey,
    };
    final categoryColor = categoryColors[report.category] ?? Colors.grey;

    final bool canDelete = currentRole.toLowerCase() == "admin" ||
        ((report.user ?? "").trim().toLowerCase() ==
            currentUserName.trim().toLowerCase());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Report Details"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: report.imagePath != null && report.imagePath!.isNotEmpty
                  ? Image.file(
                      File(report.imagePath!),
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 250,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported,
                          size: 80, color: Colors.white70),
                    ),
            ),
            const SizedBox(height: 16),

            // CATEGORY & STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    report.category,
                    style: TextStyle(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: _statusColor(report.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    report.status,
                    style: TextStyle(
                        color: _statusColor(report.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // TITLE
            Text(
              report.title,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, height: 1.3),
            ),
            const SizedBox(height: 8),

            // DATE & USER
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  "$date${(report.user != null && report.user!.isNotEmpty) ? ' by ${report.user}' : ''}",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // DESCRIPTION CARD
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Description",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        report.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // LOCATION CARD
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Location",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        report.location ?? "Not provided",
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // DELETE BUTTON
            if (canDelete)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _deleteReport(context),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text(
                    "Delete Report",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
