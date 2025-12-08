import 'package:flutter/material.dart';
import 'package:community_report/models/report_model.dart';
import 'package:community_report/db/database_report_helper.dart';

class AdminUpdateSheet extends StatefulWidget {
  final ReportModel report;

  const AdminUpdateSheet({super.key, required this.report});

  @override
  State<AdminUpdateSheet> createState() => _AdminUpdateSheetState();
}

class _AdminUpdateSheetState extends State<AdminUpdateSheet> {
  late TextEditingController notesController;
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    notesController =
        TextEditingController(text: widget.report.adminNotes ?? "");
    selectedStatus = widget.report.status;
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.85,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Update Report",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),

                const SizedBox(height: 10),

                // Status
                const Text("Status",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                Row(
                  children: [
                    _statusButton("Pending", Colors.orange),
                    const SizedBox(width: 8),
                    _statusButton("In Progress", Colors.blue),
                    const SizedBox(width: 8),
                    _statusButton("Resolve", Colors.green),
                  ],
                ),

                const SizedBox(height: 25),

                // Notes
                const Text("Admin Notes",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Add notes about this report...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Category
                const Text("Category",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(report.category),

                const SizedBox(height: 15),

                // Location
                const Text("Location",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(report.location ?? "Not provided"),

                const SizedBox(height: 15),

                // Description
                const Text("Description",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(report.description),

                const SizedBox(height: 30),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      report.status = selectedStatus;
                      report.adminNotes = notesController.text;
                      await ReportDBHelper.instance.updateReport(report);
                      Navigator.pop(context, true);
                    },
                    child: const Text("Save Changes",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Status button widget
  Widget _statusButton(String value, Color color) {
    final isSelected = selectedStatus == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedStatus = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
