// กำหนดชื่อตารางไว้ในตัวแปร
final String tableStatistics = 'statistics';
 
// กำหนดฟิลด์ข้อมูลของตาราง
class StatisticFields {
  // สร้างเป็นลิสรายการสำหรับคอลัมน์ฟิลด์
  static final List<String> values = [
    id,title, timeAlert ,timeAccept ,status
  ];
 
  // กำหนดแต่ละฟิลด์ของตาราง ต้องเป็น String ทั้งหมด
  static final String id = '_id'; // ตัวแรกต้องเป็น _id ส่วนอื่นใช้ชื่อะไรก็ได้
  static final String title = 'title';
  static final String timeAlert = 'timeAlert';
  static final String timeAccept = 'timeAccept';
  static final String status = 'status';
  
 
}
 
// ส่วนของ Data Model ของหนังสือ
class Statistic {
  final int? id; // จะใช้ค่าจากที่ gen ในฐานข้อมูล
  final String title;
  final String timeAlert;
  final String timeAccept;
  final String status;
  
 
  // constructor
  const Statistic({
    this.id,
    
    required this.title,
    required this.timeAlert,
    required this.timeAccept,
    required this.status
  
  });
 
  // ฟังก์ชั่นสำหรับ สร้างข้อมูลใหม่ โดยรองรับแก้ไขเฉพาะฟิลด์ที่ต้องการ
  Statistic copy({
   int? id,
   String? title,
   String? timeAlert,
   String? timeAccept,
   String? status,
   
  }) =>
    Statistic(
      id: id ?? this.id, 
   
      title: title ?? this.title,
      timeAlert: timeAlert ?? this.timeAlert,
      timeAccept: timeAccept ?? this.timeAccept,
      status: status ?? this.status
      
    );
 
  // สำหรับแปลงข้อมูลจาก Json เป็น Book object
  static Statistic fromJson(Map<String, Object?> json) =>  
    Statistic(
      id: json[StatisticFields.id] as int?,
      title: json[StatisticFields.title] as String,
      timeAlert: json[StatisticFields.timeAlert] as String,
      timeAccept: json[StatisticFields.timeAccept] as String,
      status: json[StatisticFields.status] as String,
      
    );
 
  // สำหรับแปลง Book object เป็น Json บันทึกลงฐานข้อมูล
  Map<String, Object?> toJson() => {
    StatisticFields.id: id,
      
    StatisticFields.title: title,
    StatisticFields.timeAlert: timeAlert,
    StatisticFields.timeAccept: timeAccept,
    StatisticFields.status: status,
    
  };
 

}