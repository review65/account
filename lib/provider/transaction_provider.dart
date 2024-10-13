import 'package:flutter/foundation.dart';
import 'package:account/databases/transaction_db.dart';
import 'package:account/models/transactions.dart';

class TransactionProvider with ChangeNotifier {
  List<KpopBand> transactions = [];

  List<KpopBand> getTransaction() {
    return transactions;
  }

  void initData() async {
    var db = TransactionDB(dbName: 'transactions.db');
    transactions = await db.loadAllData();
    print('Loaded transactions: ${transactions.length}'); // Debug log
    
    notifyListeners();
  }

  Future<void> addTransaction(KpopBand transaction) async {
    var db = TransactionDB(dbName: 'transactions.db');
    await db.insertDatabase(transaction);
    
    transactions = await db.loadAllData();
    print('Loaded transactions: ${transactions.length}'); // Debug log
    notifyListeners(); // อัปเดต UI

  }

  void deleteTransaction(int? index) async {
    var db = TransactionDB(dbName: 'transactions.db');
    await db.deleteDatabase(index);
    transactions = await db.loadAllData();
    print('Loaded transactions: ${transactions.length}'); // Debug log
    notifyListeners();
  }

  void updateTransaction(KpopBand transaction) async {
    var db = TransactionDB(dbName: 'transactions.db');
    await db.updateDatabase(transaction);
    transactions = await db.loadAllData();
    print('Loaded transactions: ${transactions.length}'); // Debug log
    notifyListeners();
  }
}
