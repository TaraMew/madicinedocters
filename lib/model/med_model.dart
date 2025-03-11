// กำหนดชื่อตารางไว้ในตัวแปร
final String tableMeds = 'meds';
 
// กำหนดฟิลด์ข้อมูลของตาราง
class MedFields {
  // สร้างเป็นลิสรายการสำหรับคอลัมน์ฟิลด์
  static final List<String> values = [
    id, med_id, title, data
  ];
 
  // กำหนดแต่ละฟิลด์ของตาราง ต้องเป็น String ทั้งหมด
  static final String id = '_id'; // ตัวแรกต้องเป็น _id ส่วนอื่นใช้ชื่อะไรก็ได้
  static final String med_id = 'med_id';
  static final String title = 'title';
  static final String data = 'data';
 
}
 
// ส่วนของ Data Model ของหนังสือ
class Med {
  final int? id; // จะใช้ค่าจากที่ gen ในฐานข้อมูล
  final int med_id; 
  final String title;
  final String data;
  
 
  // constructor
  const Med({
    this.id,
    required this.med_id,
    required this.title,
    required this.data,
  
  });
 
  // ฟังก์ชั่นสำหรับ สร้างข้อมูลใหม่ โดยรองรับแก้ไขเฉพาะฟิลด์ที่ต้องการ
  Med copy({
   int? id,
   int? med_id,
   String? title,
   String? data,
   
  }) =>
    Med(
      id: id ?? this.id, 
      med_id: med_id ?? this.med_id,
      title: title ?? this.title,
      data: data ?? this.data,
      
    );
 
  // สำหรับแปลงข้อมูลจาก Json เป็น Book object
  static Med fromJson(Map<String, Object?> json) =>  
    Med(
      id: json[MedFields.id] as int?,
      med_id: json[MedFields.med_id] as int,
      title: json[MedFields.title] as String,
      data: json[MedFields.data] as String,
      
    );
 
  // สำหรับแปลง Book object เป็น Json บันทึกลงฐานข้อมูล
  Map<String, Object?> toJson() => {
    MedFields.id: id,
    MedFields.med_id: med_id,    
    MedFields.title: title,
    MedFields.data: data,
    
  };
 

}