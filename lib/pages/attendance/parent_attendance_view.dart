import 'package:flutter/material.dart';

class ParentAttendanceView extends StatefulWidget {
  final String parentId;

  const ParentAttendanceView({
    super.key,
    required this.parentId,
  });

  @override
  State<ParentAttendanceView> createState() => _ParentAttendanceViewState();
}

class _ParentAttendanceViewState extends State<ParentAttendanceView> {
  @override
  void initState() {
    super.initState();
    // TODO: Load child's attendance data using widget.parentId
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การมาเรียนของบุตรหลาน'),
      ),
      body: Center(
        child: Text('Parent ID: ${widget.parentId}'),
      ),
    );
  }
}
