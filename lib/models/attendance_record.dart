class AttendanceRecord {
  final String id;
  final String subjectId;
  final String date;
  final String time;
  final String status;
  final String? note;

  AttendanceRecord({
    required this.id,
    required this.subjectId,
    required this.date,
    required this.time,
    required this.status,
    this.note,
  });

  factory AttendanceRecord.fromMap(String id, Map<String, dynamic> data) {
    return AttendanceRecord(
      id: id,
      subjectId: data['subject_id'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      status: data['status'] ?? '',
      note: data['note'],
    );
  }
}
