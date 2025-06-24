

enum AttendanceStatus { present, absent, leave, late }

class StudentAttendance {
  final String id;
  final String name;
  AttendanceStatus status;

  StudentAttendance ({
    required this.id,
    required this.name,
    this.status = AttendanceStatus.absent,
  });
}
