import 'dart:developer';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicinedocter/pdf_service.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../db/statistic_db.dart';
import '../model/statistic_model.dart';

class report extends StatefulWidget {
  final String valueFromMed;
  const report({Key? key, required this.valueFromMed}) : super(key: key);

  @override
  State<report> createState() => _reportState();
}

class _reportState extends State<report> {
  late StatisticsDatabase _db; // อ้างอิงฐานข้อมูล
  late Future<List<Statistic>> statistics; // ลิสรายการหนังสือ

  var date = [];
  var alert = [];
  var accept = [];
  var status = [];
  int CYes = 0;
  int CNo = 0;
  int CCancel = 0;

  int i = 0;

  @override
  void initState() {
    // อ้างอิงฐานข้อมูล
    _db = StatisticsDatabase.instance;
    statistics = _db.getStatistic(widget.valueFromMed); 
   
    super.initState();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            AppLocalizations.of(context)!.report + " " + widget.valueFromMed),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title:
                          Text(AppLocalizations.of(context)!.areyousure + " ?"),
                      content: Text(
                          AppLocalizations.of(context)!.youareaboutdeletethis),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () {
                              clearBook();
                              Navigator.pop(context);
                              setState(() {});
                            },
                            child: Text(AppLocalizations.of(context)!.yes)),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(AppLocalizations.of(context)!.no)),
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.delete_forever),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Statistic>>(
          // ชนิดของข้อมูล
          future: statistics, // ข้อมูล Future
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  TextButton(onPressed: _createPDF, child: Text("PDF")),
                  Expanded(
                    // ส่วนของลิสรายการ
                    child: snapshot.data!.isNotEmpty // กำหนดเงื่อนไขตรงนี้
                        ? ListView.separated(
                            // กรณีมีรายการ แสดงปกติหนด controller ที่จะใช้งานร่วม
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              Statistic statistic = snapshot.data![index];
                              Color bgColor = Colors.green;
                              Widget card;
                              var acceptTime = statistic.timeAccept;

                              DateTime timeAlert =
                                  DateTime.parse(statistic.timeAlert);
                              var alarmTime =
                                  DateFormat('hh:mm aa').format(timeAlert);
                              var dateAlarm =
                                  DateFormat('d/M/y').format(timeAlert);

                              if (acceptTime != '--:--') {
                                var timeAccept = DateTime.parse(acceptTime);
                                acceptTime =
                                    DateFormat('hh:mm aa').format(timeAccept);
                              }
                               date.add(dateAlarm);
                               alert.add(alarmTime);
                               accept.add(acceptTime);
                               status.add(statistic.status);

                               if(statistic.status == 'Yes') {
                                CYes++;
                                bgColor = Colors.green;
                              }
                               if(statistic.status == 'Cancel') {
                                CCancel++;
                                bgColor = Color.fromARGB(255, 184, 172, 69);
                              }

                              if (statistic.status == 'No') {
                                CNo++;
                                bgColor = Colors.red;
                              }
                              card = Card(
                                  margin:
                                      const EdgeInsets.all(5.0), // การเยื้องขอบ
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(statistic.title +
                                            "\n" +
                                            AppLocalizations.of(context)!.date +
                                            " : " +
                                            dateAlarm),
                                        subtitle: Text(
                                            AppLocalizations.of(context)!
                                                    .alarmtime +
                                                " : " +
                                                alarmTime +
                                                "\n" +
                                                AppLocalizations.of(context)!
                                                    .accepttime +
                                                " : " +
                                                acceptTime),
                                        leading: CircleAvatar(
                                            radius: 25 ,
                                            backgroundColor: bgColor,
                                            foregroundColor: Colors.white,
                                            child: Text(statistic.status)),
                                        onTap: () {},
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

  Future<void> clearBook() async {
    await _db
        .deleteStatisticAll(widget.valueFromMed); // ทำคำสั่งลบข้อมูลทั้งหมด
    setState(() {
      statistics = _db.getStatistic(widget.valueFromMed); // แสดงรายการหนังสือ
    });
  }

  Future<void> _createPDF() async{
    PdfDocument document = PdfDocument();
    final page = document.pages.add();
    int num = 1;

    page.graphics.drawString(widget.valueFromMed + " Report", PdfStandardFont(PdfFontFamily.helvetica, 30)  );

    page.graphics.drawString('Yes : $CYes', PdfStandardFont(PdfFontFamily.helvetica, 16), bounds: const Rect.fromLTWH(0, 70, 0, 0));
    page.graphics.drawString('No : $CNo', PdfStandardFont(PdfFontFamily.helvetica, 16), bounds: const Rect.fromLTWH(0, 100, 0, 0));
    page.graphics.drawString('Cancel : $CCancel', PdfStandardFont(PdfFontFamily.helvetica, 16), bounds: const Rect.fromLTWH(0, 130, 0, 0));
    
    //page.graphics.drawString(status.length.toString(), PdfStandardFont(PdfFontFamily.helvetica, 16), bounds: const Rect.fromLTWH(0, 50, 0, 0));
     

    PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(font: PdfStandardFont(PdfFontFamily.helvetica,16),cellPadding: PdfPaddings(left: 5,right: 2,top: 2,bottom: 2));



    grid.columns.add(count: 5);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = "No.";
    header.cells[1].value = "Date";
    header.cells[2].value = "Alert time";
    header.cells[3].value = "Accept time";
    header.cells[4].value = "Status";
    
    PdfGridRow row = grid.rows.add();
    for(int i=0;i<status.length;i++){
    row.cells[0].value = '$num';
    row.cells[1].value = date[i];
    row.cells[2].value = alert[i];
    row.cells[3].value = accept[i];
    row.cells[4].value = status[i];
    if(i<status.length-1){row = grid.rows.add();}
    
    num++;

    }

    
  

    
   


    //page    
    grid.draw(page: page,bounds: const Rect.fromLTWH(0, 180, 0, 0));
    List<int> bytes = document.saveSync() ;
    document.dispose();

    saveAndLaunchFile(bytes,widget.valueFromMed+'.pdf');
  }
}
