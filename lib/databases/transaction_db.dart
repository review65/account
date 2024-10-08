import 'dart:io';
import 'package:account/models/kpop_band.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:account/models/kpop_band.dart'; // Assuming you have this model file for KpopBand

class KpopBandDB {
  String dbName;

  KpopBandDB({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, dbName);

    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  Future<int> insertDatabase(KpopBand band) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('kpopBand');

    var keyID = await store.add(db, {
      "name": band.name,
      "members": band.members.map((m) => {"name": m.name, "age": m.age}).toList(),
      "debutDate": band.debutDate.toIso8601String(),
      "albums": band.albums,  // This assumes albums is a List<String>
      "genre": band.genre,
    });

    db.close(); // Closing the DB after the operation
    return keyID;
  }

  Future<List<KpopBand>> loadAllData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('kpopBand');
    
    // Retrieve data from database
    var snapshot = await store.find(db, finder: Finder(sortOrders: [SortOrder(Field.key, false)]));
    
    // Convert snapshot to List of KpopBand
    List<KpopBand> bands = [];
    for (var record in snapshot) {
      var members = (record['members'] as List).map((m) => Member(name: m['name'], age: m['age'])).toList();
      List<String> albums = [];
      if (record['albums'] != null && record['albums'] is List) {
      albums = List<String>.from(record['albums'] as List);
      }
      bands.add(KpopBand(
        keyID: record.key,
        name: record['name'].toString(),
        members: members,
        debutDate: DateTime.parse(record['debutDate'].toString()),
        albums: albums,
        genre: record['genre'].toString(),
      ));
    }

    db.close(); // Close database after fetching
    return bands;
  }

  Future<void> deleteDatabase(int? index) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('kpopBand');
    
    // Delete specific record
    await store.delete(db, finder: Finder(filter: Filter.equals(Field.key, index)));
    
    db.close(); // Close DB after deletion
  }
}
