import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:medicinedocter/main.dart';
import 'package:medicinedocter/model/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class settingPage extends StatefulWidget {
  static const routeName = '/setting';

  @override
  State<settingPage> createState() => _settingPageState();
}

class _settingPageState extends State<settingPage> {
  Future<void> lg_ch(String id) async {
    MyApp.setLocale(context, Locale(id, ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.setting),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            TextButton(
              onPressed: () {
                lg_ch('th');
              },
              child: Text("ไทย"),
              
            ),
            TextButton(
                onPressed: () {
                  lg_ch('en');
                },
                child: Text("English")),
            TextButton(
                onPressed: () {
                  lg_ch('km');
                },
                child: Text("ខ្មែរ")),
            TextButton(
                onPressed: () {
                  lg_ch('my');
                },
                child: Text("မြန်မာ")),
            TextButton(
                onPressed: () {
                  lg_ch('vi');
                },
                child: Text("Việt Nam")),
          ],
        ),
      ),
    );
  }
}
