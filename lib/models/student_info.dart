class StudentInfo {
  final String id;
  final String fname;
  final String lname;
  final String className;

  StudentInfo({
    required this.id,
    required this.fname,
    required this.lname,
    required this.className,
  });

  factory StudentInfo.fromMap(String id, Map<String, dynamic> data) {
    return StudentInfo(
      id: id,
      fname: data['fname'] ?? '',
      lname: data['lname'] ?? '',
      className: data['class_name'] ?? '',
    );
  }

  String get fullName => "$fname $lname";
}
