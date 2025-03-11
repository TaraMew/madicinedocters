import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:get/get.dart';
import 'package:medicinedocter/pages/report.dart';
import 'package:medicinedocter/pages/translatePage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicinedocter/pages/alarm.dart';
import 'package:medicinedocter/pages/camera.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../db/med_db.dart';
import '../model/med_model.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'form.dart';

class Meds extends StatefulWidget {
  static const routeName = '/med';

  const Meds({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MedsState();
  }
}

class _MedsState extends State<Meds> {
  bool textScanning = false;
  XFile? imageFile;
  String scannedText = "";
  final FlutterTts flutterTts = FlutterTts();
  late MedsDatabase _db; // อ้างอิงฐานข้อมูล
  late Future<List<Med>> meds; // ลิสรายการหนังสือ
  int i = 0; // จำลองตัวเลขการเพิ่่มจำนวน

  @override
  Future _speak(String txt) async {
    await flutterTts.setPitch(1);
    await flutterTts.speak(txt);
  }

  Future _stop() async {
    await flutterTts.stop();
  }

  void initState() {
    // อ้างอิงฐานข้อมูล
    _db = MedsDatabase.instance;
    meds = _db.readAllBook(); // แสดงรายการหนังสือ
    super.initState();
  }

  // คำสั่งลบรายการทั้งหมด
  Future<void> clearBook() async {
    await _db.deleteAll(); // ทำคำสั่งลบข้อมูลทั้งหมด
    setState(() {
      meds = _db.readAllBook(); // แสดงรายการหนังสือ
    });
  }

  // คำสั่งลบเฉพาะรายการที่กำหนดด้วย id ที่ต้องการ
  Future<void> deleteBook(int id) async {
    await _db.delete(id); // ทำคำสั่งลบข้มูลตามเงื่อนไข id
    setState(() {
      meds = _db.readAllBook(); // แสดงรายการหนังสือ
    });
  }

  // จำลองทำคำสั่งแก้ไขรายการ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.medicineDoctor),
        centerTitle: true,
        actions: <Widget>[
          //
          IconButton(
            // onPressed: () => clearBook(), // ปุ่มลบข้อมูลทั้งหมด
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return FormScreen();
              }));
            },

            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Med>>(
          // ชนิดของข้อมูล
          future: meds, // ข้อมูล Future
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
                              Med med = snapshot.data![index];

                              Widget card; // สร้างเป็นตัวแปร
                              card = Card(
                                  margin:
                                      const EdgeInsets.all(5.0), // การเยื้องขอบ
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(med.title),
                                        onTap: () {
                                          _viewDetail(med
                                              .id!); // กดเลือกรายการให้แสดงรายละเอียด
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return CameraScreen();
          }));
        },
        child: const Icon(Icons.camera),
      ),
    );
  }

  // สร้างฟังก์ชั่นจำลองการแสดงรายละเอียดข้อมูล
  Future<Widget?> _viewDetail(int id) async {
    Future<Med> med = _db.readBook(id); // ดึงข้อมูลจากฐานข้อมูลมาแสดง

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<Med>(
              future: med,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var med = snapshot.data!;

                  return Container(
                    height: 500,
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.iD + ' : ${med.id}'),
                        SizedBox(
                          height: 5,
                        ),
                        Text(AppLocalizations.of(context)!.title +
                            ' : ${med.title}'),
                        SizedBox(
                          height: 5,
                        ),
                        Text(AppLocalizations.of(context)!.data +
                            ' : ${med.data}'),
                        Text(" "),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () => _speak(med.data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.stop),
                              onPressed: () => _stop(),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return alarm(
                                      valueFromMed: med.title,
                                    );
                                  }));
                                },
                                child:
                                    Text(AppLocalizations.of(context)!.alarm)),
                            TextButton(
                              child: Text(AppLocalizations.of(context)!.search),
                              onPressed: () async {
                                String url =
                                    'https://www.google.com/search?q=' +
                                        med.title;
                                Uri link;
                                link = Uri.parse(url);

                                if (!await launchUrl(link)) {
                                  throw Exception('Could not launch $link');
                                }
                              },
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return translatePage(
                                      valueFromMed: med.data,
                                    );
                                  }));
                                },
                                child: Text(
                                    AppLocalizations.of(context)!.translate)),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return report(
                                      valueFromMed: med.title,
                                    );
                                  }));
                                },
                                child: Text(AppLocalizations.of(context)!.report))
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        FilledButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(AppLocalizations.of(context)!
                                            .areyousure +
                                        " ?"),
                                    content: Text(AppLocalizations.of(context)!
                                        .youareaboutdeletethis),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () {
                                            deleteBook(med.id!);
                                            Navigator.pop(context);
                                            setState(() {});
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .yes)),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .no)),
                                    ],
                                  );
                                });
                          },
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red[400]), // ลบข้อมูล
                          child: Text(AppLocalizations.of(context)!.delete),
                        )
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  // กรณี error
                  return Text('${snapshot.error}');
                }
                return const RefreshProgressIndicator();
              });
        });
  }
}
