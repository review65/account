import 'package:account/models/transactions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:account/provider/transaction_provider.dart';
import 'edit_screen.dart';
import 'form_screen.dart';
import 'package:account/databases/transaction_db.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<KpopBand> transactions;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kpop Bands"),
        backgroundColor: Colors.black,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          print(
              'Current transactions: ${provider.transactions.length}'); // Debug
          if (provider.transactions.isEmpty) {
            return const Center(
              child:
                  Text('ไม่มีข้อมูลวง', style: TextStyle(color: Colors.black)),
            );
          } else {
            return ListView.builder(
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                var band = provider.transactions[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  child: ExpansionTile(
                    title: Text(
                      band.bandName,
                      style: const TextStyle(
                        fontSize: 28, // Increase the font size
                        fontWeight: FontWeight.bold, // Make the name bold
                        color: Colors.black, // Keep it black for visibility
                      ),
                    ),
                    children: [
                      ListTile(
                        title: Text('เอเจนซี่: ${band.agency}',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.black)),
                      ),
                      ListTile(
                        title: Text(
                          'แนวดนตรี: ${band.genre.join(', ')}',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                        ),
                      ),
                      ListTile(
                        subtitle: Text(
                          'เดบิวต์: ${DateFormat('dd MMM yyyy').format(band.debutDate)}',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'อัลบั้ม: ${band.albums.join(', ')}',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                        ),
                      ),
                      const Divider(), // เพื่อแยกสมาชิก
                      const Text('สมาชิก:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      for (var member in band.members)
                        ListTile(
                          title: Text(
                            'ชื่อ: ${member.name}',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.black),
                          ),
                          subtitle: Text(
                            'วันเกิด: ${DateFormat('dd MMM yyyy').format(member.dob)}, อายุ: ${member.age} ปี',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ListTile(
                        title: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: const Text('แก้ไข',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditScreen(
                                    statement: band), // นำไปที่หน้าแก้ไข
                              ),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.deleteTransaction(band.keyID);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () async {
          // Navigate to FormScreen and await the result
          final newBand = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormScreen()),
          );

          if (newBand != null) {
            Provider.of<TransactionProvider>(context, listen: false)
                .addTransaction(newBand);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
