import 'package:dakara_weighbridge/Json/listproduct_json.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  final databaseName = "daprin.db";

  String listProductTable = '''
  CREATE TABLE IF NOT EXISTS listproducts (
  productID INTEGER PRIMARY KEY AUTOINCREMENT,
  productName TEXT NOT NULL,
  productKeterangan TEXT NOT NULL,
  )''';

  String pengeluaranTable = '''
  CREATE TABLE IF NOT EXISTS pengeluaran (
  pengeluaranID INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  notaNumber TEXT,
  namaPengeluaran TEXT NOT NULL,
  jenisPengeluaran TEXT NOT NULL,
  price INTEGER NOT NULL,
  statusPengeluaran TEXT,
  namaPJ TEXT,
  productSN TEXT
  )''';
  // productStock = Ready/Sold Out  1/0
  // productStatus = Lunas/Belum lunas

  String projectTable = '''
  CREATE TABLE IF NOT EXISTS projects (
  projectID INTEGER PRIMARY KEY AUTOINCREMENT,
  namaPT TEXT NOT NULL,
  jenisProject TEXT NOT NULL,
  projectPIC TEXT NOT NULL,
  projectPH TEXT,
  projectSJ TEXT,
  projectBA TEXT,
  projectPO TEXT,
  projectFaktur TEXT,
  datePH TEXT,
  dateSJ TEXT,
  dateBA TEXT,
  datePO TEXT,
  dateFaktur TEXT,
  dateSend,
  )''';
  // jenisProject = "Penggantian Alat/Service/Tera Ulang"

  Future<Database> init() async {
    // final databasePath = await getApplicationDocumentsDirectory();
    // print(databasePath);
    // final path = "$databasePath/$databaseName";
    final path = "Users/user/Documents/Flutter/daprint/$databaseName";

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        //Tables
        await db.execute(listProductTable);
        await db.execute(pengeluaranTable);
        await db.execute(projectTable);
      },
    );
  }

  //******* CRUD Methods *********//

  //======= listproducts ================================
  // Get Product
  Future<List<ListProductJson>> getListProducts() async {
    final Database db = await init();
    List<Map<String, Object?>> result = await db.query("listproducts");
    return result.map((e) => ListProductJson.fromJson(e)).toList();
  }

  // Add Product
  Future<int> addListProduct(ListProductJson product) async {
    final Database db = await init();
    return db.insert("listproducts", product.toJson());
  }

  // Delete Product
  Future<int> deleteListProduct(int id) async {
    final Database db = await init();
    return db.delete("listproducts", where: "productID = ?", whereArgs: [id]);
  }

  // Update Product
  Future<int> updateListProduct(ListProductJson product) async {
    final Database db = await init();
    return db.rawUpdate(
      "update listproducts set productName = ?, productKeterangan = ? where productID = ?",
      [product.productName, product.productKeterangan, product.productID],
    );
  }

  // Update Stock
  // Future<int> updateStock(int id, int stock) async {
  //   final Database db = await init();
  //   return db.rawUpdate(
  //     "update listproducts set productStock = ? where productID = ?",
  //     [stock, id],
  //   );
  // }

  //======= Pengeluaran =======================================
  // Get Pengeluaran
  // Future<List<PengeluaranJson>> getAllPengeluaran() async {
  //   final Database db = await init();
  //   List<Map<String, Object?>> result = await db.query("pengeluaran");
  //   return result.map((e) => PengeluaranJson.fromJson(e)).toList();
  // }

  // // Add Pengeluaran
  // Future<int> addPengeluaran(PengeluaranJson pengeluaran) async {
  //   final Database db = await init();
  //   return db.insert("pengeluaran", pengeluaran.toJson());
  // }

  // // Update Pengeluaran
  // Future<int> updatePengeluaran(PengeluaranJson pengeluaran) async {
  //   final Database db = await init();
  //   return db.rawUpdate(
  //     "update pengeluaran set date = ?, notaNumber = ?, namaPengeluaran = ?, jenisPengeluaran = ?, price = ?, statusPengeluaran = ?, namaPJ = ? where pengeluaranID = ?",
  //     [
  //       pengeluaran.date,
  //       pengeluaran.notaNumber,
  //       pengeluaran.namaPengeluaran,
  //       pengeluaran.jenisPengeluaran,
  //       pengeluaran.price,
  //       pengeluaran.statusPengeluaran,
  //       pengeluaran.namaPj,
  //       pengeluaran.pengeluaranID,
  //     ],
  //   );
  // }

  // // Delete Pengeluaran
  // Future<int> deletePengeluaran(int id) async {
  //   final Database db = await init();
  //   return db.delete(
  //     "pengeluaran",
  //     where: "pengeluaranID = ?",
  //     whereArgs: [id],
  //   );
  // }

  //======= PROJECT =====================================
  // Future<List<ProjectJson>> getProject() async {
  //   final Database db = await init();
  //   List<Map<String, Object?>> result = await db.query("projects");
  //   return result.map((e) => ProjectJson.fromJson(e)).toList();
  // }

  // // Add Project
  // Future<int> addProject(ProjectJson projects) async {
  //   final Database db = await init();
  //   return db.insert("projects", projects.toJson());
  // }

  // // Update Data Project
  // Future<int> updateProduct(ProjectJson prj) async {
  //   final Database db = await init();
  //   return db.rawUpdate(
  //     "update projects set namaPT = ?, jenisProject = ?, projectPIC = ?, datePH = ?, dateSJ = ?, dateBA = ?, datePO = ?, dateFaktur = ?, dateSend = ? where projectID = ?",
  //     [
  //       prj.namaPT,
  //       prj.jenisProject,
  //       prj.projectPIC,
  //       prj.datePH,
  //       prj.dateSJ,
  //       prj.dateBA,
  //       prj.datePO,
  //       prj.dateFaktur,
  //       prj.dateSend,
  //       prj.projectID,
  //     ],
  //   );
  // }

  // // Delete Project
  // Future<int> deleteProject(int id) async {
  //   final Database db = await init();
  //   return db.delete("projects", where: "projectID = ?", whereArgs: [id]);
  // }
}
