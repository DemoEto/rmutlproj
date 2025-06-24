import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmutlproj/models/student_addtendance.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<StudentAttendance> students = [];
  List<StudentAttendance> filteredStudents = [];
  String? selectedClass;

  List<String> availableClasses =
      []; // สมมติว่ามีห้องพวกนี้ หรือดึงจาก Firestore ก็ได้

  @override
  void initState() {
    super.initState();
    _loadAvailableClasses(); // เรียกโหลดห้องเรียน
  }

  Future<void> _loadAvailableClasses() async {
    final snapshot = await db.collection('Classes').get();

    List<String> classNames =
        snapshot.docs.map((doc) {
          return doc.id;
        }).toList();

    setState(() {
      availableClasses = classNames;
    });
  }

  void _searchStudent(String query) {
    final result =
        students.where((StudentAttendance) {
          return StudentAttendance.name.contains(query);
        }).toList();

    setState(() {
      filteredStudents = result;
    });
  }

  Future<void> _loadStudentsFromClass(String className) async {
    final snapshot =
        await db
            .collection('Students')
            .where('class_name', isEqualTo: className)
            .get();

    List<StudentAttendance> loadedStudents =
        snapshot.docs.map((doc) {
          String fullName =
              "${doc.data()['fname'] ?? ''} ${doc.data()['lname'] ?? ''}"
                  .trim();
          // <- ประกอบชื่อ
          return StudentAttendance(
            id: doc.id,
            name: fullName,
            status: AttendanceStatus.absent, // หรือกำหนด default อื่นก็ได้
          );
        }).toList();

    setState(() {
      students = loadedStudents;
      filteredStudents = loadedStudents;
    });
  }

  void _markAllPresent() {
    setState(() {
      for (var StudentAttendance in students) {
        StudentAttendance.status = AttendanceStatus.present;
      }
      filteredStudents = students;
    });
  }

  void _saveAttendance() async {
    final now = DateTime.now();
    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    final batch = db.batch(); // ใช้ batch เพื่อเขียนหลายอันพร้อมกัน

    for (var StudentAttendance in students) {
      final attendanceRef =
          db
              .collection('Students')
              .doc(StudentAttendance.id)
              .collection('Attendance')
              .doc(); // สร้าง doc id อัตโนมัติ

      batch.set(attendanceRef, {
        'subject_id': 'รหัสรายวิชา', // หรือเปลี่ยนให้รับค่าจากหน้าจอ
        'date': formattedDate,
        'time': formattedTime,
        'status': _getStatusText(StudentAttendance.status),
        'note': '', // เผื่อใส่หมายเหตุในอนาคต
      });
    }

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('บันทึกการเช็คชื่อสำเร็จ!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // helper function แปลง status เป็นข้อความ
  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'มาเรียน';
      case AttendanceStatus.absent:
        return 'ขาดเรียน';
      case AttendanceStatus.leave:
        return 'ลา';
      case AttendanceStatus.late:
        return 'มาสาย';
    }
  }

  void _selectStatus(StudentAttendance StudentAttendance, AttendanceStatus status) {
    setState(() {
      StudentAttendance.status = status;
    });
  }

  Widget _buildStatusButton(
    StudentAttendance StudentAttendance,
    AttendanceStatus status,
    String label,
    Color color,
  ) {
    bool isSelected = StudentAttendance.status == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectStatus(StudentAttendance, status),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เช็คชื่อรายวิชา'),
        actions: [
          if (students.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ElevatedButton.icon(
                onPressed: _saveAttendance,
                icon: const Icon(Icons.save, size: 18, color: Colors.white),
                label: const Text(
                  'บันทึก',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Dropdown เลือกห้องเรียน
            DropdownButton<String>(
              hint: const Text("เลือกห้องเรียน"),
              value: selectedClass,
              items:
                  availableClasses.map((className) {
                    return DropdownMenuItem(
                      value: className,
                      child: Text(className),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedClass = value;
                    students = [];
                    filteredStudents = [];
                  });
                  _loadStudentsFromClass(value);
                }
              },
            ),
            const SizedBox(height: 12),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _searchStudent,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'ค้นหาชื่อนักเรียน...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (students.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _markAllPresent,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('ติ๊กว่ามาเรียนทั้งหมด'),
                ),
              ),
            const SizedBox(height: 12),

            Expanded(
              child:
                  students.isEmpty
                      ? const Center(child: Text('กรุณาเลือกห้องเรียน'))
                      : ListView.builder(
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final StudentAttendance = filteredStudents[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    StudentAttendance.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildStatusButton(
                                        StudentAttendance,
                                        AttendanceStatus.present,
                                        'มาเรียน',
                                        Colors.green,
                                      ),
                                      _buildStatusButton(
                                        StudentAttendance,
                                        AttendanceStatus.absent,
                                        'ขาดเรียน',
                                        Colors.red,
                                      ),
                                      _buildStatusButton(
                                        StudentAttendance,
                                        AttendanceStatus.leave,
                                        'ลา',
                                        Colors.orange,
                                      ),
                                      _buildStatusButton(
                                        StudentAttendance,
                                        AttendanceStatus.late,
                                        'มาสาย',
                                        Colors.blue,
                                      ),
                                    ],
                                  ),
                                ],
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
}
