import 'package:flutter/material.dart';
import 'package:rmutlproj/pages/attendance/teacher_attendance_view.dart';
import 'package:rmutlproj/pages/attendance/student_attendance_view.dart';
import 'package:rmutlproj/pages/attendance/parent_attendance_view.dart';

class AttendanceNavigationPage extends StatelessWidget {
  final String role;
  final String userId;

  const AttendanceNavigationPage({
    required this.role,
    required this.userId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case 'teacher':
        return TeacherAttendanceView(); // ครูเลือกนักเรียน
      case 'student':
        return StudentAttendanceView(studentId: userId); // นักเรียนดูของตนเอง
      case 'parent':
        return ParentAttendanceView(parentId: userId); // ผปค. ดูของลูก
      default:
        return const Scaffold(body: Center(child: Text('ไม่รู้จักบทบาทผู้ใช้')));
    }
  }
}
