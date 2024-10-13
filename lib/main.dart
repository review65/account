import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:account/provider/transaction_provider.dart';
import 'package:account/screens/home_screen.dart';
import 'package:account/screens/form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TransactionProvider(),
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.black, // สีพื้นฐานเป็นสีดำ
          scaffoldBackgroundColor: Colors.white, // สีพื้นหลังเป็นสีขาว
          textTheme: const TextTheme(
            bodyLarge:
                TextStyle(color: Colors.black), // กำหนดสีตัวอักษรเป็นสีดำ
            bodyMedium: TextStyle(color: Colors.black),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black, // สี AppBar เป็นสีดำ
            foregroundColor: Colors.white, // สีข้อความใน AppBar เป็นสีขาว
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black, // ข้อความในปุ่มเป็นสีขาว
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.black), // สีของ label
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
        home: const HomeScreen(), // ควรใช้ HomeScreen ตรงนี้
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kpop Bands'),
      ),
      body: const HomeScreen(), // Displays the list of Kpop bands
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
