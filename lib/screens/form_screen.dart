import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:account/models/transactions.dart';
import 'package:account/provider/transaction_provider.dart';
import 'package:account/databases/transaction_db.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final formKey = GlobalKey<FormState>();
  final bandNameController = TextEditingController();
  final genreController = TextEditingController();
  final debutDateController = TextEditingController();
  final albumsController = TextEditingController();
  final agencyController = TextEditingController();

  List<Member> members = []; // เก็บข้อมูลสมาชิก

  final memberNameController = TextEditingController();
  final memberBtdController = TextEditingController();

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มข้อมูลวง Kpop'),
        backgroundColor: Colors.black,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration:const InputDecoration(
                labelText: 'ชื่อวง',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              controller: bandNameController,
              validator: (String? str) {
                if (str == null || str.isEmpty) {
                  return 'กรุณากรอกชื่อวง';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'ชื่อเอเจนซี่',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              controller: agencyController,
              validator: (String? str) {
                if (str == null || str.isEmpty) {
                  return 'กรุณากรอกชื่อเอเจนซี่';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'แนวดนตรี (แยกด้วย ,)',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              controller: genreController,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'วันที่เดบิวต์ (YYYY-MM-DD)',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              controller: debutDateController,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'อัลบั้ม (แยกด้วย ,)',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              controller: albumsController,
            ),
            const SizedBox(height: 20),
            const Text(
              'สมาชิกวง',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            for (var i = 0; i < members.length; i++)
              ListTile(
                title: Text('ชื่อ: ${members[i].name},วันเกิด: ${[
                  members[i].dob
                ]} ,อายุ: ${members[i].age}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      members.removeAt(i);
                    });
                  },
                ),
              ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'ชื่อสมาชิก',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              controller: memberNameController,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'วันเดือนปีเกิด (YYYY-MM-DD)',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              controller: memberBtdController,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('เพิ่มสมาชิก',
                  style: TextStyle(color: Colors.white)),
              onPressed: () {
                // เพิ่มสมาชิกแต่ไม่กลับไปหน้า Home
                if (memberNameController.text.isNotEmpty) {
                  // ตรวจสอบวันเดือนปีเกิด
                  DateTime? birthday;
                  try {
                    birthday = DateTime.parse(memberBtdController.text);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('กรุณากรอกวันเดือนปีเกิด'),
                      ),
                    );
                    return; // หยุดการทำงานถ้าไม่ได้กรอก
                  }

                  // ตรวจสอบว่าค่า birthday ไม่เป็น null ก่อนที่จะส่งค่าไปยังตัวแปร
                  // ใช้ตัวแปร birthday ที่เป็น non-null ในการคำนวณ
                  int age = calculateAge(
                      birthday); // ส่ง birthday ที่เป็น DateTime แน่ๆ
                  setState(() {
                    members.add(Member(
                      name: memberNameController.text,
                      dob: birthday!, // ตรวจสอบก่อนแล้วว่าไม่เป็น null
                    ));
                  });
                  memberNameController.clear();
                  memberBtdController.clear();
                }
                if (debutDateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณากรอกวันที่เดบิวต์')),
                  );
                  return;
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child:
                    const Text('บันทึก', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    List<String> albums = albumsController.text
                        .split(',')
                        .map((album) => album.trim())
                        .toList();
                    List<String> genres = genreController.text
                        .split(',')
                        .map((genre) => genre.trim())
                        .toList();
                    if (members.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('กรุณาเพิ่มสมาชิก'),
                        ),
                      );
                      return;
                    }
                    var band = KpopBand(
                      bandName: bandNameController.text,
                      agency: agencyController.text,
                      members: members, // รายชื่อสมาชิกที่บันทึกไว้
                      debutDate: DateTime.now(), // ใส่วันที่เดบิวต์
                      albums: albums, // ใส่ข้อมูลอัลบั้ม
                      genre: genres, // ใส่แนวดนตรี
                    );

                    Provider.of<TransactionProvider>(context, listen: false)
                        .addTransaction(band); // Debug log
                    Navigator.pop(context); // กลับไปหน้า Home หลังบันทึก
                  }
                })
          ],
        ),
      ),
    );
  }
}

int calculateAge(DateTime birthday) {
  DateTime today = DateTime.now();
  int age = today.year - birthday.year;

  // ตรวจสอบว่าผ่านวันเกิดของปีนี้หรือยัง ถ้ายังต้องลบออก 1 ปี
  if (today.month < birthday.month ||
      (today.month == birthday.month && today.day < birthday.day)) {
    age--;
  }
  return age;
}
