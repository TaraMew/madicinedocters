import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medicinedocter/pages/report.dart';
import 'package:medicinedocter/pages/translatePage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicinedocter/pages/alarm.dart';
import '../db/statistic_db.dart';
import '../model/statistic_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'form.dart';

class notiPage extends StatefulWidget {
  static const routeName = '/noti';

  const notiPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _notiPageState();
  }
}

class _notiPageState extends State<notiPage> {
 
  late StatisticsDatabase _db; // อ้างอิงฐานข้อมูล
  late Future<List<Statistic>> statistics; // ลิสรายการหนังสือ
  int i = 0; // จำลองตัวเลขการเพิ่่มจำนวน
  String dbDate = DateFormat('y-MM-d').format(DateTime.now());
  

  @override
  
  

  void initState() {
    // อ้างอิงฐานข้อมูล
    _db = StatisticsDatabase.instance;
    statistics = _db.readAllStatistic(dbDate); // แสดงรายการหนังสือ
    super.initState();
  }
   Future<void> editStatistic(Statistic statistic,String timeAccept,String choice) async {
      // เลื่อกเปลี่ยนเฉพาะส่วนที่ต้องการ โดยใช้คำสั่ง copy
      statistic = statistic.copy(
        title: statistic.title,
        timeAlert: statistic.timeAlert,
        timeAccept: timeAccept,
        status: choice,
        
      );      
      await _db.update(statistic); // ทำคำสั่งอัพเดทข้อมูล
     
      setState(() {
          statistics = _db.readAllStatistic(dbDate);
      });
      
    }   

      
    Future<void> newStatistic(
      String title, String timeAlert, String timeAccept) async {
    _db = StatisticsDatabase.instance;
    Statistic statistic = Statistic(
        title: title,
        timeAlert: timeAlert,
        timeAccept: timeAccept,
        status: 'Cancel');
    Statistic new_statistic =
        await _db.create(statistic); // ทำคำสั่งเพิ่มข้อมูลใหม่
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notification),
        centerTitle: true,
        
      ),
      body: Center(
        child: FutureBuilder<List<Statistic>>(
          // ชนิดของข้อมูล
          future: statistics, // ข้อมูล Future
          builder: (context, snapshot) {
            if (snapshot.hasData) {
               
              return Column(
                children: [
                  Expanded(
                    // ส่วนของลิสรายการ
                    child: snapshot.data!.isNotEmpty // กำหนดเงื่อนไขตรงนี้
                        ? ListView.separated(
                            // กรณีมีรายการ แสดงปกติหนด controller ที่จะใช้งานร่วม
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              Statistic statistic = snapshot.data![index];

                              Widget card; // สร้างเป็นตัวแปร
                              DateTime timeAlert = DateTime.parse(statistic.timeAlert);
                              var alarmTime =
                              DateFormat('hh:mm aa d/M/y').format(timeAlert);
                              var chHour = int.parse( DateFormat('hh').format(timeAlert));
                              var chDate = int.parse( DateFormat('d').format(timeAlert));
                              var bgColor = Color.fromARGB(255, 31, 141, 232);
                             
                              
                              
                              card = Card(
                                
                                  margin:
                                      const EdgeInsets.all(5.0), // การเยื้องขอบ
                                  child: Column(
                                    
                                    children: [
                                      
                                      ListTile(
                                        leading: CircleAvatar(child: Text(statistic.status),foregroundColor: Colors.white,backgroundColor: bgColor,),
                                        title: Text(statistic.title ),
                                        subtitle: Text(alarmTime),
                                        trailing:  IconButton(
                                                    onPressed: () {showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(AppLocalizations.of(context)!
                                            .takemedicine),
                                    content: Text(AppLocalizations.of(context)!.haveyoutakenyourmedicineyet+" ?"),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () async{
                                            await editStatistic(statistic,DateTime.now().toString(),"Yes");
                                            //statistics = _db.readAllStatistic();
                                           
                                            Navigator.pop(context);
                                            
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .yes)),
                                      TextButton(
                                          onPressed: () async{
                                           await editStatistic(statistic,"--:--","No");
                                          // statistics = _db.readAllStatistic();
                                          
                                            Navigator.pop(context);
                                            
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .no)),
                                      TextButton(
                                          onPressed: () async{
                                           await newStatistic(statistic.title, statistic.timeAlert, DateTime.now().toString());
                                            Navigator.pop(context);
                                            setState(() {});
                                          },
                                          child: Text(AppLocalizations.of(context)!.cancel))
                                    ],
                                  );
                                });}, 
                                                    icon: const Icon(Icons.notifications_rounded),
                                                  ),
                                                  
                                        onTap: () {
                                        //  _viewDetail(statistic
                                        //      .id!); // กดเลือกรายการให้แสดงรายละเอียด
                                        },
                                      ),
                                    ],
                                  ));

                              
                                 
                                 
                                return card;
                                             
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(),
                          )
                        : Center(
                            child: Text(AppLocalizations.of(context)!
                                .noitems)), // กรณีไม่มีรายการ
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              // กรณี error
              return Text('${snapshot.error}');
            }
            // กรณีสถานะเป็น waiting ยังไม่มีข้อมูล แสดงตัว loading
            return const RefreshProgressIndicator();
          },
        ),
      ),
     
    );
  }


  
}
