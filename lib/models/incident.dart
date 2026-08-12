class Incident {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String? assignedTo;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.assignedTo,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      assignedTo: json['assignedTo']?.toString(),
    );
  }
}
