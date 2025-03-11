import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medicinedocter/pages/Homepage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medicinedocter/pages/Med.dart';
import 'package:medicinedocter/pages/alarm.dart';
import 'package:medicinedocter/pages/started.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:medicinedocter/pages/translatePage.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    
    
Future<void> main() async {
  
   
  WidgetsFlutterBinding.ensureInitialized();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
          
          });
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload.toString());
      
    }
  });
  

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale){
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}
 class _MyAppState extends State<MyApp>{
  Locale? _locale;

  setLocale(Locale locale){
    setState(() {
      _locale = locale;
    });
  }
  @override
   Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => StartedPage(),
        '/med': (BuildContext context) => Meds(),
        '/homepage': (BuildContext context) => HomePage(),
        
      },
     localizationsDelegates: AppLocalizations.localizationsDelegates,
     supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StartedPage(),
    );
  }
 }