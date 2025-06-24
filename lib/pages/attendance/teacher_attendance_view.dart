import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmutlproj/models/attendance_record.dart';
import 'package:rmutlproj/models/student_info.dart';

class TeacherAttendanceView extends StatefulWidget {
  @override
  _TeacherAttendanceViewState createState() => _TeacherAttendanceViewState();
}

class _TeacherAttendanceViewState extends State<TeacherAttendanceView> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String? selectedStudentId;
  List<StudentInfo> students = [];
  List<AttendanceRecord> records = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final snapshot = await db.collection('Students').get();
    setState(() {
      students = snapshot.docs.map((doc) => StudentInfo.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<void> _loadAttendance(String studentId) async {
    final snapshot = await db
        .collection('Students')
        .doc(studentId)
        .collection('Attendance')
        .get();

    setState(() {
      records = snapshot.docs.map((doc) => AttendanceRecord.fromMap(doc.id, doc.data())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ดูข้อมูลการมาเรียน")),
      body: Column(
        children: [
          DropdownButton<String>(
            hint: Text("เลือกนักเรียน"),
            value: selectedStudentId,
            items: students.map((student) {
              return DropdownMenuItem(
                value: student.id,
                child: Text(student.fullName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedStudentId = value);
                _loadAttendance(value);
              }
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return ListTile(
                  title: Text('${record.date} - ${record.status}'),
                  subtitle: Text(record.subjectId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
