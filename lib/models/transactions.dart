class KpopBand {
  final int? keyID;
  final String bandName;
  final String agency; // เพิ่มฟิลด์ agency
  final List<Member> members;
  final DateTime debutDate;
  final List<String> albums;
  final List<String> genre;
  

  KpopBand({
    this.keyID,
    required this.bandName,
    required this.agency, // กำหนดเป็น required
    required this.members,
    required this.debutDate,
    required this.albums,
    required this.genre,
  });
}


class Member {
  final String name;

  final DateTime dob; // เปลี่ยนจาก age เป็น dob

  

  int get age {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }
  Member({required this.name, required this.dob});
}
