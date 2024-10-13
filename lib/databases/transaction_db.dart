import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:account/models/transactions.dart';

class TransactionDB {
  String dbName;

  static var instance;

  TransactionDB({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, dbName);

    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  Future<int> insertDatabase(KpopBand statement) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('kpop_band');

    var keyID = await store.add(db, {
      "bandName": statement.bandName,
      "agency": statement.agency,
      "members": statement.members
          .map((member) => {
                'name': member.name,
                'dob': member.dob.toIso8601String(),
                'age': member.age,
              })
          .toList(),
      "debutDate": statement.debutDate.toIso8601String(),
      "albums": statement.albums,
      "genre": statement.genre, // เก็บ genre เป็น List
    });
    print('Inserted keyID: $keyID'); // Debug log
    db.close();
    return keyID;
  }

  DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Handle invalid date format
      print("Invalid date format: $dateString");
      return null;
    }
  }

  Future<List<KpopBand>> loadAllData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('kpop_band');
    var snapshot = await store.find(db,
        finder: Finder(sortOrders: [SortOrder(Field.key, false)]));

    List<KpopBand> bands = [];
    for (var record in snapshot) {
      // ตรวจสอบว่าข้อมูล members เป็น List หรือไม่
      List<Member> members = [];
      if (record['members'] is List) {
        members = (record['members'] as List).map((memberData) {
          return Member(
            name: memberData['name'].toString(),
            dob: DateTime.parse(memberData['dob'].toString()),
          );
        }).toList();
      }
      DateTime? debutDate = record['debutDate'] != null
          ? DateTime.tryParse(record['debutDate'].toString())
          : null;

      // ตรวจสอบว่า albums และ genre เป็น List หรือไม่
      List<String> albums = [];
      if (record['albums'] is List) {
        albums = (record['albums'] as List).map((e) => e.toString()).toList();
      }

      List<String> genres = [];
      if (record['genre'] is List) {
        genres = (record['genre'] as List).map((e) => e.toString()).toList();
      }

      bands.add(KpopBand(
        keyID: record.key,
        bandName: record['bandName'].toString(),
        agency: record['agency'].toString(),
        members: members,
        debutDate:
            debutDate ?? DateTime.now(), // ใช้วันที่ปัจจุบันหากไม่สามารถแปลงได้
        albums: albums,
        genre: genres,
      ));
      try {
        DateTime debutDate = DateTime.parse(record['debutDate'].toString());
      } catch (e) {
        print("Invalid debut date format for record key: ${record.key}");
      }
    }
    db.close();
    return bands;
  }

  deleteDatabase(int? index) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('kpop_band');
    await store.delete(db,
        finder: Finder(filter: Filter.equals(Field.key, index)));
    db.close();
  }

  updateDatabase(KpopBand statement) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('kpop_band');
    var filter = Finder(filter: Filter.equals(Field.key, statement.keyID));
    await store.update(
        db,
        {
          "bandName": statement.bandName,
          "members": statement.members
              .map((member) =>
                  {'name': member.name, 'dob': member.dob.toIso8601String()})
              .toList(),
          "debutDate": statement.debutDate.toIso8601String(),
          "albums": statement.albums,
          "genre": statement.genre,
        },
        finder: filter);
    db.close();
  }
}
