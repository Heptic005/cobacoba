import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  final String _databaseName = "dakara_weighbridge.db";

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await init();
    return _database!;
  }

  Future<Database> init() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    // Ensure the directory exists
    try {
      await Directory(documentsDirectory.path).create(recursive: true);
    } catch (_) {}

    final db = await openDatabase(path, version: 1, onCreate: _onCreate);

    // Ensure admin exists (Seeding for existing databases)
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['admin'],
    );
    if (result.isEmpty) {
      final hashed = _hashPassword('password');
      await db.insert('users', {
        'username': 'admin',
        'password': hashed,
        'role': 'owner',
      });
    }

    return db;
  }

  Future _onCreate(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // Seed initial admin user if not exists
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['admin'],
    );
    if (result.isEmpty) {
      final hashed = _hashPassword('password');
      await db.insert('users', {
        'username': 'admin',
        'password': hashed,
        'role': 'owner',
      });
    }

    // Suppliers Table
    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        alamat TEXT,
        kabupaten_kota TEXT,
        kecamatan TEXT,
        kode_pos TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Customers Table
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        alamat TEXT,
        no_telp TEXT,
        range INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Barangs Table
    await db.execute('''
      CREATE TABLE barangs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        kode_barang TEXT UNIQUE,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Transaksis Table
    await db.execute('''
      CREATE TABLE transaksis (
        no_tiket INTEGER PRIMARY KEY AUTOINCREMENT,
        jam_masuk TEXT,
        jam_keluar TEXT,
        total_harga INTEGER,
        bruto INTEGER,
        tara INTEGER,
        netto INTEGER,
        netto_setelah_potongan INTEGER,
        plat_mobil TEXT,
        nama_supir TEXT,
        supplier_id INTEGER,
        customer_id INTEGER,
        barang_id INTEGER,
        no_do TEXT,
        no_container TEXT,
        suhu INTEGER,
        harga_per_kg INTEGER,
        keterangan TEXT,
        paraf_supir INTEGER DEFAULT 0,
        paraf_operator INTEGER DEFAULT 0,
        paraf_manager INTEGER DEFAULT 0,
        paraf_kepala_gudang INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (supplier_id) REFERENCES suppliers (id),
        FOREIGN KEY (customer_id) REFERENCES customers (id),
        FOREIGN KEY (barang_id) REFERENCES barangs (id)
      )
    ''');

    // Tokens Table
    await db.execute('''
      CREATE TABLE tokens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        token TEXT NOT NULL,
        user_id INTEGER,
        expires_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Settings Table
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL UNIQUE,
        value TEXT
      )
    ''');

    // Insert default settings
    await db.insert('settings', {'key': 'baud_rate', 'value': '9600'});
  }

  // Generic CRUD Helpers
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  // Users-specific helpers
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await queryAll('users');
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    final res = await db.query('users', where: 'username = ?', whereArgs: [username]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> createUser(Map<String, dynamic> userData) async {
    // Hash password before inserting if provided
    if (userData.containsKey('password') && userData['password'] is String) {
      userData['password'] = _hashPassword(userData['password'] as String);
    }
    return await insert('users', userData);
  }

  Future<int> updateUser(int id, Map<String, dynamic> userData) async {
    return await update('users', userData, id);
  }

  Future<int> deleteUserById(int id) async {
    return await delete('users', id);
  }

  /// Simple authentication helper. Returns the user row on success, otherwise null.
  Future<Map<String, dynamic>?> authenticateUser(String username, String password) async {
    final user = await getUserByUsername(username);
    if (user == null) return null;
    final stored = user['password'] as String?;
    if (stored == null) return null;
    // If stored value appears to be our salted hash format (salt:$hex), verify normally.
    final parts = stored.split(':');
    if (parts.length == 2 && parts[1].startsWith(r'$')) {
      return _verifyPassword(stored, password) ? user : null;
    }

    // Legacy plaintext password: verify directly and migrate to hashed password.
    if (stored == password) {
      final newHashed = _hashPassword(password);
      // update user password in DB
      if (user.containsKey('id')) {
        final id = user['id'] as int;
        await updateUser(id, {'password': newHashed});
        // return updated user
        return await getUserById(id);
      }
      return user;
    }

    return null;
  }

  // --- Password hashing helpers (SHA256 with per-user salt) ---
  String _generateSalt([int length = 16]) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hashPassword(String password, {String? salt}) {
    final s = salt ?? _generateSalt();
    final bytes = utf8.encode(s + password);
    final digest = sha256.convert(bytes);
    return '$s:\$${digest.toString()}';
  }

  bool _verifyPassword(String stored, String password) {
    // stored format: salt:$<hexhash>
    final parts = stored.split(':');
    if (parts.length != 2) return false;
    final salt = parts[0];
    final hashPart = parts[1];
    final bytes = utf8.encode(salt + password);
    final digest = sha256.convert(bytes).toString();
    return hashPart == '\$' + digest;
  }
}
