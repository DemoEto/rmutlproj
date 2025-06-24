import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmutlproj/models/attendance_record.dart';


class StudentAttendanceView extends StatefulWidget {
  final String studentId;

  const StudentAttendanceView({
    super.key,
    required this.studentId,
  });

  @override
  _StudentAttendanceViewState createState() => _StudentAttendanceViewState();
}

class _StudentAttendanceViewState extends State<StudentAttendanceView> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  List<AttendanceRecord> records = [];

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final snapshot = await db
        .collection('Students')
        .doc(widget.studentId)
        .collection('Attendance')
        .get();

    setState(() {
      records = snapshot.docs.map((doc) => AttendanceRecord.fromMap(doc.id, doc.data())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ข้อมูลมาเรียนของฉัน")),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return ListTile(
            title: Text('${record.date} - ${record.status}'),
            subtitle: Text(record.subjectId),
          );
        },
      ),
    );
  }
}
