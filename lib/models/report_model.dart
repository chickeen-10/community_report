class ReportModel {
  int? id;
  String title;
  String description;
  String category;
  String? location;
  String? imagePath;
  String status;
  DateTime? date;
  String? user; // creator
  String? adminNotes;

  ReportModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.location,
    this.imagePath,
    this.status = "Pending",
    this.date,
    this.user,
    this.adminNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'imagePath': imagePath,
      'status': status,
      'date': date?.toIso8601String(),
      'user': user,
      'adminNotes': adminNotes,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] as int?,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'],
      imagePath: map['imagePath'],
      status: map['status'] ?? "Pending",
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      user: map['user'],
      adminNotes: map['adminNotes'],
    );
  }
}
