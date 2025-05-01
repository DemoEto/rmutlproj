import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedSampleData() async {
  final db = FirebaseFirestore.instance;

  // เพิ่มครู
  await db.collection('Teachers').doc('t001').set({
    'fname': 'สุชาติ',
    'lname': 'ใจดี',
  });

  // เพิ่มห้องเรียน
  await db.collection('Classes').doc('ม.301').set({
    'teacherId': 't001',
  });

  // เพิ่มนักเรียน
  await db.collection('Students').doc('s001').set({
    'fname': 'อนันต์',
    'lname': 'สายบุญ',
    'tel': '0812345678',
    'address': '99 หมู่ 1 ต.เมือง',
    'class_name': 'ม.301',
  });

  await db.collection('Students').doc('s002').set({
    'fname': 'สมหญิง',
    'lname': 'ใจสู้',
    'tel': '0823456789',
    'address': '101 หมู่ 5 ต.กลางเมือง',
    'class_name': 'ม.301',
  });

  // เพิ่มวิชา
  await db.collection('Subjects').doc('MAT301').set({
    'name': 'คณิตศาสตร์ ม.3',
    'class_name': 'ม.301',
    'teacher_id': 't001',
  });

  print("🎉 เพิ่มข้อมูลตัวอย่างเรียบร้อยแล้ว");
}
