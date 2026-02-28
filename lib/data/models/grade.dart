class Grade {
  final String id;
  final String subject;
  final String teacher;
  final int value;
  final String type;
  final DateTime date;

  Grade({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.value,
    required this.type,
    required this.date,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      teacher: json['teacher'] ?? '',
      value: json['value'] ?? 0,
      type: json['type'] ?? 'экзамен',
      date: DateTime.parse(json['date']),
    );
  }
}