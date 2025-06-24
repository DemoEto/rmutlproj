import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryPage extends StatefulWidget {
  final String userId; // ID ของผู้ใช้งาน
  final String role;   // 'teacher', 'student', 'parent'
  final String? studentId; // เฉพาะผู้ปกครอง จะรู้ว่าเป็นของลูก

  const AttendanceHistoryPage({
    super.key,
    required this.userId,
    required this.role,
    this.studentId,
  });

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String? selectedStudentId;
  List<Map<String, dynamic>> attendanceRecords = [];
  List<Map<String, dynamic>> studentsList = [];

  @override
  void initState() {
    super.initState();
    if (widget.role == 'teacher') {
      _loadStudentList();
    } else {
      selectedStudentId = widget.role == 'parent' ? widget.studentId : widget.userId;
      _loadAttendance();
    }
  }

  Future<void> _loadStudentList() async {
    final snapshot = await db.collection('Students').get();
    final list = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': '${doc['fname']} ${doc['lname']}',
      };
    }).toList();
    setState(() {
      studentsList = list;
    });
  }

  Future<void> _loadAttendance() async {
    if (selectedStudentId == null) return;
    final subSnapshot = await db
        .collection('Students')
        .doc(selectedStudentId)
        .collection('Attendance')
        .get();

    final records = subSnapshot.docs.map((doc) {
      return {
        'date': doc['date'],
        'subject': doc['subject_id'],
        'status': doc['status'],
      };
    }).toList();

    setState(() {
      attendanceRecords = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการมาเรียนรายเดือน'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.role == 'teacher')
              DropdownButton<String>(
                hint: const Text('เลือกนักเรียน'),
                value: selectedStudentId,
                items: studentsList
                    .map((student) => DropdownMenuItem<String>(
                          value: student['id'],
                          child: Text(student['name']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStudentId = value;
                    attendanceRecords = [];
                  });
                  _loadAttendance();
                },
              ),
            const SizedBox(height: 16),
            Expanded(
              child: attendanceRecords.isEmpty
                  ? const Center(child: Text('ไม่มีข้อมูล'))
                  : ListView.builder(
                      itemCount: attendanceRecords.length,
                      itemBuilder: (context, index) {
                        final record = attendanceRecords[index];
                        final formattedDate = DateFormat('dd/MM/yyyy')
                            .format(DateTime.parse(record['date']));
                        return ListTile(
                          leading: Icon(
                            Icons.calendar_today,
                            color: _getStatusColor(record['status']),
                          ),
                          title: Text('วันที่: $formattedDate'),
                          subtitle: Text('วิชา: ${record['subject']}'),
                          trailing: Text(
                            record['status'],
                            style: TextStyle(
                              color: _getStatusColor(record['status']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'มา':
        return Colors.green;
      case 'สาย':
        return Colors.orange;
      case 'ขาด':
        return Colors.red;
      case 'ลา':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
