import 'package:account/models/transactions.dart';
import 'package:account/provider/transaction_provider.dart';
import 'package:account/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditScreen extends StatefulWidget {
  KpopBand statement;

  EditScreen({super.key, required this.statement});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final bandNameController = TextEditingController();
  final agencyController = TextEditingController();
  final genreController = TextEditingController();
  final debutDateController = TextEditingController();
  final albumsController = TextEditingController();
  List<Member> members = [];
  final formKey = GlobalKey<FormState>(); // เพิ่ม formKey

  final memberNameController = TextEditingController();
  final memberBtdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bandNameController.text = widget.statement.bandName;
    agencyController.text = widget.statement.agency;
    genreController.text = widget.statement.genre != null
        ? widget.statement.genre.join(', ') // แยกแนวเพลงด้วยคอมมา
        : ''; // ป้องกัน null
    debutDateController.text = widget.statement.debutDate.toIso8601String();
    albumsController.text = widget.statement.albums != null
        ? widget.statement.albums.join(', ')
        : ''; // ป้องกัน null
    members = widget.statement.members;
  }

  void _showEditMemberDialog(int index) {
    var member = members[index];
    var nameController = TextEditingController(text: member.name);
    var dobController = TextEditingController(text: member.dob.toIso8601String().split("T").first); // แสดงในรูปแบบ YYYY-MM-DD
    
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('แก้ไขสมาชิก'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ชื่อสมาชิก'),
              ),
              TextField(
                controller: dobController,
                decoration: const InputDecoration(labelText: 'วันเกิดสมาชิก (YYYY-MM-DD)'),
                onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode()); // หยุดเปิดคีย์บอร์ด
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: member.dob,
                  firstDate: DateTime(1800),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  dobController.text = selectedDate.toIso8601String().split("T").first; // แสดงในรูปแบบ YYYY-MM-DD
                }
              },
            ),
          ],
        ),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('บันทึก'),
              onPressed: () {
                setState(() {
                  members[index] = Member(
                    name: nameController.text,
                    dob: DateTime.parse(dobController.text),
                    
                  );
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูล K-pop'),
      ),
      body: Form(
        key: formKey, // ใช้งาน formKey
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'ชื่อวง',
                labelStyle: TextStyle(
                  fontSize: 20, // ขยายขนาดตัวอักษร
                  fontWeight: FontWeight.bold, // ทำตัวหนา
                  color: Colors.black,
                ),
                border: OutlineInputBorder(),
              ),
              controller: bandNameController,
              validator: (String? str) {
                if (str == null || str.isEmpty) {
                  return 'กรุณากรอกข้อมูล';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'เอเจนซี่', // ทำให้เป็นตัวพิมพ์ใหญ่
                labelStyle: TextStyle(fontSize: 20, color: Colors.black),
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
                labelText: 'แนวดนตรี (แยกด้วย , )',
                labelStyle: TextStyle(fontSize: 20,color: Colors.black),
                border: OutlineInputBorder(), // อัปเดตเพื่อรองรับหลายแนวเพลง
              ),
              controller: genreController,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'วันที่เดบิวต์ (YYYY-MM-DD)',
                labelStyle: TextStyle(fontSize: 20,color: Colors.black),
                border: OutlineInputBorder(),
              ),
              controller: debutDateController,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'อัลบั้ม (แยกด้วย , )',
                labelStyle: TextStyle(fontSize: 20,color: Colors.black),
                border: OutlineInputBorder(),
              ),
              controller: albumsController,
            ),
            const SizedBox(height: 20),
            const Text(
              'MEMBERS', // ทำให้เป็นตัวพิมพ์ใหญ่
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            for (var i = 0; i < members.length; i++)
              ListTile(
                title:
                    Text('ชื่อ: ${members[i].name}, อายุ: ${members[i].age}',style: const TextStyle(fontSize: 20)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // เปิด dialog เพื่อแก้ไขข้อมูลสมาชิก
                        _showEditMemberDialog(i);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          members.removeAt(i);
                        });
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            // เพิ่มสมาชิกใหม่
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'ชื่อสมาชิกใหม่',
                border: OutlineInputBorder(),
              ),
              controller: memberNameController,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'วันเกิดสมาชิกใหม่ (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              controller: memberBtdController,
              onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1800),
                lastDate: DateTime.now(),
              );
              if (selectedDate != null) {
                memberBtdController.text = selectedDate.toIso8601String().split("T").first;
              }
            },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('เพิ่มสมาชิก', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (memberNameController.text.isNotEmpty &&
                    memberBtdController.text.isNotEmpty) {
                  setState(() {
                    members.add(Member(
                      name: memberNameController.text,
                      dob: DateTime.parse(memberBtdController.text),
                      
                    ));
                  });
                  memberNameController.clear();
                  memberBtdController.clear();
                }
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              child: const Text('แก้ไขข้อมูล'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // แยกแนวเพลงออกเป็น List
                  List<String> genres = genreController.text
                      .split(',')
                      .map((genre) => genre.trim())
                      .toList();

                  // แยกอัลบั้มออกเป็น List
                  List<String> albums = albumsController.text
                      .split(',')
                      .map((album) => album.trim())
                      .toList();

                  var statement = KpopBand(
                    keyID: widget.statement.keyID,
                    bandName: bandNameController.text,
                    agency: agencyController.text,
                    members: members,
                    debutDate: DateTime.parse(debutDateController.text),
                    albums: albums,
                    genre: genres, // เพิ่มการรองรับหลายแนวเพลง
                  );

                  var provider =
                      Provider.of<TransactionProvider>(context, listen: false);
                  provider.updateTransaction(statement);

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const HomeScreen();
                  }));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
