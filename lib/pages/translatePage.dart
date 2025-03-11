import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
class translatePage extends StatefulWidget {
  final String valueFromMed;
  const translatePage({Key? key, required this.valueFromMed}) : super(key: key);

  @override
  State<translatePage> createState() => _translatePageState();
}

class _translatePageState extends State<translatePage> {
  String translated = 'Translation';
 final FlutterTts flutterTts = FlutterTts();
  String tl = 'Select Language';
  List<String> items = [
    'Choose Language',
    'ไทย',
    'English',
    'ខ្មែរ',
    'မြန်မာ',
    'Việt Nam'
  ];
  String? selectedItem = 'Choose Language';
  @override
  Future _speak(String txt) async {
    await flutterTts.setPitch(1);
    await flutterTts.speak(txt);
  }

  Future _stop() async {
    await flutterTts.stop();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.translate),
      ),
      body: Card(
        margin: const EdgeInsets.all(12),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(widget.valueFromMed,
                            style: TextStyle(fontSize: 18)),
            const SizedBox(
              height: 8,
            ),
            DropdownButton<String>(
                value: selectedItem,
                items: items
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(fontSize: 18),
                          ),
                        ))
                    .toList(),
                onChanged: (item) async {
                    if(item == 'ไทย')tl='th';
                    if(item == 'English')tl='en';
                    if(item == 'ខ្មែរ')tl='km';
                    if(item == 'မြန်မာ')tl='my';
                    if(item == 'Việt Nam')tl='vi';
                    if(item == 'Choose language')tl='en';
                    
                  final translation =
                      await widget.valueFromMed.translate(from: 'auto', to: tl);
                  setState(() {
                    translated = translation.text;
                    selectedItem = item;


                  });
                }),
            const SizedBox(
              height: 8,
            ),
            const Divider(
              height: 32,
            ),
            Text(
              translated,
              style: const TextStyle(fontSize: 18),
            ),
            SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () => _speak(translated),
                            ),
                            IconButton(
                              icon: const Icon(Icons.stop),
                              onPressed: () => _stop(),
                            ),
                            
                          ],

                        )
          ],
        ),
      ),
    );
  }
}
