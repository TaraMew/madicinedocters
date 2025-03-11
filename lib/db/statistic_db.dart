import 'dart:async';
 
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
 
import '../model/statistic_model.dart';
 
// สร้าง class จัดการข้อมูล
class StatisticsDatabase {
  // กำหนดตัวแปรสำหรับอ้างอิงฐานข้อมูล
  static final StatisticsDatabase instance = StatisticsDatabase._init();
 
  // กำหนดตัวแปรฐานข้อมูล
  static Database? _database;
 
  StatisticsDatabase._init();
 
  Future<Database> get database async {
    // ถ้ามีฐานข้อมูลนี้แล้วคืนค่า 
    if (_database != null) return _database!;
    // ถ้ายังไม่มี สร้างฐานข้อมูล กำหนดชื่อ นามสกุล .db
    _database = await _initDB('statistics.db');
    // คืนค่าฐานข้อมูล
    return _database!;
  }
 
  // ฟังก์ชั่นสร้างฐานข้อมูล รับชื่อไฟล์ที่กำหนดเข้ามา
  Future<Database> _initDB(String filePath) async {
    // หาตำแหน่งที่จะจัดเก็บในระบบ ที่เตรียมไว้ให้
    final dbPath = await getDatabasesPath();
    // ต่อกับชื่อที่ส่งมา จะเป็น path เต็มของไฟล์
    final path = join(dbPath, filePath);
    // สร้างฐานข้อมูล และเปิดใช้งาน หากมีการแก้ไข ให้เปลี่ยนเลขเวอร์ชั่น เพิ่มขึ้นไปเรื่อยๆ
    return await openDatabase(path, version: 1, onCreate: _createDB);
 
  }
 
  // สร้างตาราง
   Future _createDB(Database db, int version) async {
     // รูปแบบข้อมูล sqlite ที่รองรับ
     final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
     final textType = 'TEXT NOT NULL';
     final boolType = 'BOOLEAN NOT NULL';
     final integerType = 'INTEGER NOT NULL';
 
    // ทำคำสั่งสร้างตาราง
     await db.execute('''
CREATE TABLE $tableStatistics (
  ${StatisticFields.id} $idType,
  
  ${StatisticFields.title} $textType,
  ${StatisticFields.timeAlert} $textType,
  ${StatisticFields.timeAccept} $textType,
  ${StatisticFields.status} $textType
  
)
''');
   } 
 
  
  Future<Statistic> create(Statistic statistic) async {
    final db = await instance.database; // อ้างอิงฐานข้อมูล
 
    final id = await db.insert(tableStatistics, statistic.toJson());
    return statistic.copy(id: id);
  }
 
  // คำสั่งสำหรับแสดงข้อมูลหนังสือตามค่า id ที่ส่งมา
  Future<Statistic> readStatistic(int id) async {
    final db = await instance.database; // อ้างอิงฐานข้อมูล
 
    // ทำคำสั่งคิวรี่ข้อมูลตามเงื่อนไข 
    final maps = await db.query(
      tableStatistics,
      columns: StatisticFields.values,
      where: '${StatisticFields.id} = ?',
      whereArgs: [id],
    );
 
    // ถ้ามีข้อมูล แสดงข้อมูลกลับออกไป
    if (maps.isNotEmpty) {
      return Statistic.fromJson(maps.first);
    } else { // ถ้าไม่มีแสดง error 
      throw Exception('ID $id not found');
    }
  }  
 
  // คำสั่งแสดงรายการหนึงสือทั้งหมด ต้องส่งกลับเป็น List
  Future<List<Statistic>> readAllStatistic(String query) async {
    final db = await instance.database; // อ้างอิงฐานข้อมูล
 
    // กำหนดเงื่อนไขต่างๆ รองรับเงื่อนไขและรูปแบบของคำสั่ง sql ตัวอย่าง
    // ใช้แค่การจัดเรียงข้อมูล
    final orderBy = '${StatisticFields.timeAlert} ASC';
    final result = await db.query(tableStatistics,where: "status =='Wait' AND timeAlert LIKE '%$query%'", orderBy: orderBy);
   
    // ข้อมูลในฐานข้อมูลปกติเป็น json string data เวลาสั่งค่ากลับต้องทำการ
    // แปลงข้อมูล จาก json ไปเป็น object กรณีแสดงหลายรายการก็ทำเป็น List
    return result.map((json) => Statistic.fromJson(json)).toList();
  }  
   Future<List<Statistic>> getStatistic(String str) async {
    List<Statistic> _statistic = [];
    final orderBy = '${StatisticFields.timeAlert} ASC';
    var db = await this.database;
    var result = await db.query(tableStatistics,where: "status != 'Wait' AND title = ?",orderBy: orderBy,whereArgs: [str]);
    result.forEach((element) {
      var statisticInfo = Statistic.fromJson(element);
      _statistic.add(statisticInfo);
    });

    return _statistic;
  }
 
  
  Future<int> update(Statistic statistic) async {
    final db = await instance.database; // อ้างอิงฐานข้อมูล
 
    // คืนค่าเป็นตัวเลขจำนวนรายการที่มีการเปลี่ยนแปลง
    return db.update(
      tableStatistics, 
      statistic.toJson(),
      where: '${StatisticFields.id} = ?',
      whereArgs: [statistic.id],      
    );
 
  }
  
 
  // คำสั่งสำหรับลบข้อมล รับค่า id ที่จะลบ
  Future<int> delete(int id) async {
    final db = await instance.database; // อ้างอิงฐานข้อมูล
 
    // คืนค่าเป็นตัวเลขจำนวนรายการที่มีการเปลี่ยนแปลง
    return db.delete(
      tableStatistics, 
      where: '${StatisticFields.id} = ?',
      whereArgs: [id],      
    );
 
  }
 
  // คำสั่งสำหรับลบข้อมูลทั้งหมด
  Future<int> deleteStatisticAll(str) async {
    final db = await instance.database; // อ้างอิงฐานข้อมูล
    // คืนค่าเป็นตัวเลขจำนวนรายการที่มีการเปลี่ยนแปลง
    return db.delete(
      tableStatistics,where: 'title = ?',whereArgs: [str]
    );
 
  }  
 
  // คำสั่งสำหรับปิดฐานข้อมูล เท่าที่ลองใช้ เราไม่ควรปิด หรือใช้คำสั่งนี้
  // เหมือนจะเป็น bug เพราะถ้าปิดฐานข้อมูล จะอ้างอิงไม่ค่อยได้ ในตัวอย่าง
  // จะไม่ปิดหรือใช้คำสั่งนี้
   Future close() async {
     final db = await instance.database; // อ้างอิงฐานข้อมูล
 
     db.close();
   }
 
}