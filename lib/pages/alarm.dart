import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:medicinedocter/alarm_helper.dart';
import 'package:medicinedocter/db/statistic_db.dart';
import 'package:medicinedocter/model/alarm_model.dart';
import 'package:medicinedocter/model/med_model.dart';
import 'package:medicinedocter/model/statistic_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../main.dart';
import '../validations/validations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class alarm extends StatefulWidget {
  static const routeName = '/alarm';
  final String valueFromMed;
  const alarm({Key? key, required this.valueFromMed}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _alarmState();
  }
}

class _alarmState extends State<alarm> with Validators {
  late StatisticsDatabase _db;
  DateTime? _alarmTime;
  DateTime? _alarmDate;
  late String _alarmTimeString;
  late String _alarmDateString;
  String _alarmDuration = '0';
  bool _isRepeatSelected = false;
  AlarmHelper _alarmHelper = AlarmHelper();
  Future<List<AlarmInfo>>? _alarms;
  List<AlarmInfo>? _currentAlarms;
  final formkey = GlobalKey<FormState>();
  List<String> med = [MedFields.data];

  // กำหนดตัวแปรสำหรับเก็บค่าที่เลือก เริ่มต้นเป็นค่าว่าง
  String _seslectedMaritalStatus = '';

  @override
  void initState() {
    tz.initializeTimeZones();
    _alarmTime = DateTime.now();
    _alarmDate = DateTime.now();
    _alarmHelper.initializeDatabase().then((value) {
      print('------database intialized');
      loadAlarms();
    });
    super.initState();
  }

  void loadAlarms() {
    _alarms = _alarmHelper.getAlarm(widget.valueFromMed);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.valueFromMed + " " + AppLocalizations.of(context)!.alarm),
        centerTitle: true,
        actions: <Widget>[
          //
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
          ),
          SizedBox(
            height: 15,
          ),
          Expanded(
            child: FutureBuilder<List<AlarmInfo>>(
              future: _alarms,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _currentAlarms = snapshot.data;
                  return ListView(
                    children: snapshot.data!.map<Widget>((alarm) {
                      var alarmTime =
                          DateFormat('hh:mm aa').format(alarm.alarmDateTime!);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xff7c94b6),
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.label,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      alarm.title!,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'avenir'),
                                    ),
                                  ],
                                ),
                                Switch(
                                  onChanged: (bool value) {},
                                  value: true,
                                  activeColor: Colors.white,
                                ),
                              ],
                            ),
                            Text(
                              alarm.dateRange!,
                              style: TextStyle(
                                  color: Colors.white, fontFamily: 'avenir'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  alarmTime,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'avenir',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700),
                                ),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.white,
                                    onPressed: () {
                                      deleteAlarm(alarm.id);
                                    }),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).followedBy([
                      DottedBorder(
                        strokeWidth: 2,
                        color: Colors.black,
                        borderType: BorderType.RRect,
                        radius: Radius.circular(24),
                        dashPattern: [5, 4],
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                          child: MaterialButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            onPressed: () {
                              DateTimeRange range = DateTimeRange(
                                  start: DateTime.now(), end: DateTime.now());
                              _alarmTimeString =
                                  DateFormat('HH:mm').format(DateTime.now());

                              _alarmDateString =
                                  DateFormat('d/M/y').format(range.start);
                              _alarmDuration = range.duration.inDays.toString();

                              showModalBottomSheet(
                                useRootNavigator: true,
                                context: context,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setModalState) {
                                      return Container(
                                        padding: const EdgeInsets.all(20),
                                        child: Form(
                                          key: formkey,
                                          child: Column(
                                            children: [
                                              TextButton(
                                                onPressed: () async {
                                                  var selectedDate =
                                                      await showDateRangePicker(
                                                    context: context,
                                                    initialDateRange: range,
                                                    firstDate: DateTime(
                                                        DateTime.now().year),
                                                    lastDate: DateTime(
                                                        DateTime.now().year +
                                                            1),
                                                  );

                                                  if (selectedDate != null) {
                                                    final now = DateTime.now();
                                                    var selectedDateTime =
                                                        DateTime(
                                                            selectedDate
                                                                .start.year,
                                                            selectedDate
                                                                .start.month,
                                                            selectedDate
                                                                .start.day,
                                                            now.hour,
                                                            now.minute);
                                                    _alarmDate =
                                                        selectedDateTime;

                                                    setModalState(() {
                                                      _alarmDuration =
                                                          selectedDate
                                                              .duration.inDays
                                                              .toString();

                                                      _alarmDateString = DateFormat(
                                                                  'd/M/y')
                                                              .format(
                                                                  selectedDate
                                                                      .start) +
                                                          " "+  " to " +
                                                          DateFormat('d/M/y')
                                                              .format(
                                                                  selectedDate
                                                                      .end);
                                                      if (_alarmDuration == '0')
                                                        _alarmDateString =
                                                            DateFormat('d/M/y')
                                                                .format(
                                                                    selectedDate
                                                                        .start);
                                                    });
                                                  }
                                                },
                                                child: Text(
                                                  _alarmDateString,
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  var selectedTime =
                                                      await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.now(),
                                                  );
                                                  if (selectedTime != null) {
                                                    final now = DateTime.now();

                                                    var selectedDateTime =
                                                        DateTime(
                                                            now.year,
                                                            now.month,
                                                            now.day,
                                                            selectedTime.hour,
                                                            selectedTime
                                                                .minute);
                                                    _alarmTime =
                                                        selectedDateTime;
                                                    setModalState(() {
                                                      _alarmTimeString =
                                                          DateFormat('HH:mm')
                                                              .format(
                                                                  selectedDateTime);
                                                    });
                                                  }
                                                },
                                                child: Text(
                                                  _alarmTimeString,
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Divider(
                                                height: 12,
                                              ),
                                              ListTile(
                                                title:
                                                    Text(widget.valueFromMed),
                                                trailing: Icon(
                                                    Icons.arrow_forward_ios),
                                              ),
                                              ListTile(
                                                title: Text(AppLocalizations.of(context)!.durations+" : " +
                                                    (int.parse(_alarmDuration) +
                                                            1)
                                                        .toString() +
                                                    " "+AppLocalizations.of(context)!.day),
                                                trailing: Icon(
                                                    Icons.arrow_forward_ios),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              FloatingActionButton.extended(
                                                onPressed: () {
                                                  var title =
                                                      widget.valueFromMed;

                                                  onSaveAlarm(true, title);
                                                },
                                                icon: Icon(Icons.alarm),
                                                label: Text(AppLocalizations.of(
                                                        context)!
                                                    .save),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                              // scheduleAlarm();
                            },
                            child: Column(
                              children: <Widget>[
                                Image.asset(
                                  'assets/add_alarm.png',
                                  scale: 1.5,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Add Alarm',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'avenir'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ]).toList(),
                  );
                }
                return Center(
                  child: Text(
                    'Loading..',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void scheduleAlarm(
      DateTime scheduledNotificationDate,DateTime scheduledNotificationTime,int dateRange, AlarmInfo alarmInfo,
      {required bool isRepeating}) async {
    var scheduledNotificationDateTime = DateTime(
      scheduledNotificationDate.year,
      scheduledNotificationDate.month,
      scheduledNotificationDate.day,
      scheduledNotificationTime.hour,
      scheduledNotificationTime.minute,
      scheduledNotificationTime.second

    );


    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      channelDescription: 'Channel for Alarm notification',
      icon: 'ic_launcher',
      sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
      largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
    );

    var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      sound: 'a_long_cold_sting.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
      print(dateRange);
     for (int i = 0; i <= dateRange; i++) {
      
       await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Title : ',
      alarmInfo.title,
      tz.TZDateTime.from(scheduledNotificationDateTime.add(Duration(days: i)), tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

     };
    

   
    
  }

  void onSaveAlarm(bool _isRepeating, String title) {
    DateTime? scheduleAlarmDateTime;
    DateTime? scheduleAlarmDateStart;
    int scheduleDateRange= int.parse(_alarmDuration);

    
    
      scheduleAlarmDateStart = _alarmDate;
      scheduleAlarmDateTime = _alarmTime;
      var scheduleAlarmDateTime0 = DateTime(
        scheduleAlarmDateStart!.year,
        scheduleAlarmDateStart.month,
        scheduleAlarmDateStart.day,
        scheduleAlarmDateTime!.hour,
        scheduleAlarmDateTime.minute,
        scheduleAlarmDateTime.second,
      );
    
    var alarmInfo = AlarmInfo(
        alarmDateTime: scheduleAlarmDateTime0,
        gradientColorIndex: _currentAlarms!.length,
        title: title,
        dateRange: _alarmDateString);

    _alarmHelper.insertAlarm(alarmInfo);

    for(int i=0;i<=scheduleDateRange;i++){
      print(scheduleAlarmDateTime0.add(Duration(days: i)).toString());
      newStatistic(title, scheduleAlarmDateTime0.add(Duration(days: i)).toString(), '00');
    };
    
    if (scheduleAlarmDateTime != null && scheduleAlarmDateStart != null) {
      scheduleAlarm(scheduleAlarmDateStart,scheduleAlarmDateTime,scheduleDateRange, alarmInfo,
          isRepeating: _isRepeating);
    }
    Navigator.pop(context);
    loadAlarms();
  }

  Future<void> newStatistic(
      String title, String timeAlert, String timeAccept) async {
    _db = StatisticsDatabase.instance;
    Statistic statistic = Statistic(
        title: title,
        timeAlert: timeAlert,
        timeAccept: timeAccept,
        status: 'Wait');
    Statistic new_statistic =
        await _db.create(statistic); // ทำคำสั่งเพิ่มข้อมูลใหม่
  }

  void deleteAlarm(int? id) {
    _alarmHelper.delete(id);
    //unsubscribe for notification
    loadAlarms();
  }
}
