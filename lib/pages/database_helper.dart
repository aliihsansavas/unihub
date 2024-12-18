import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'communityinfo.db';
  static const _databaseVersion = 1;

  static const table = 'community_info';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnDescription = 'description';
  static const columnCategory = 'category';
  static const columnRules = 'rules';
  static const columnImage = 'image';

  // Singleton yapısı
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

   DatabaseHelper._init();

  // Veritabanı bağlantısı oluşturuluyor
  Future<Database> get _db async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'communityinfo.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE community_info (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            description TEXT,
            category TEXT,
            rules TEXT,
            image TEXT
          )
        ''');
      },
    );
    return db;
  }

  // Veritabanını başlatmak
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    print("Veritabanı şu dizine kaydedildi: $path"); // Veritabanı yolunu konsola yazdır
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // Veritabanı oluşturma işlemi
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnDescription TEXT NOT NULL,
            $columnCategory TEXT NOT NULL,
            $columnRules TEXT NOT NULL,
            $columnImage TEXT NOT NULL
          )
          ''');
  }

  // Tüm toplulukları alıyoruz
  Future<List<Map<String, dynamic>>> getAllCommunities() async {
    final db = await _db;
    final List<Map<String, dynamic>> result = await db.query('community_info');
    return result;
  }

  // Topluluk eklemek için
  Future<int> insert(Map<String, dynamic> community) async {
    final db = await _db;
    return await db.insert('community_info', community);
  }

  // Topluluğun resim adını güncelle
  Future<void> updateCommunityImage(int id, String imageName) async {
    final db = await _db;
    await db.update(
      'communityinfo',
      {'image': imageName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
