import 'package:flutter/material.dart';
import 'package:medicinedocter/pages/alarm.dart';
import 'Homepage.dart';
import 'Med.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StartedPage extends StatefulWidget {
  const StartedPage({super.key});

  @override
  State<StartedPage> createState() => _StartedPageState();
}

class _StartedPageState extends State<StartedPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
          child: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          Container(
            margin: EdgeInsets.only(top: 50),
            height: size.height / 1.8,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Image.asset(
              "assets/Logo_MDA_3.png",
              height: 300,
              width: 300,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  AppLocalizations.of(context)!.welcometoMedicineDocterApp,
                
                  style: TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                      fontSize: 24),
                ),
                const SizedBox(
                  height: 32,
                ),
                InkWell(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return HomePage();
                  })),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(16)),
                    child:  Center(
                      child: Text(
                         AppLocalizations.of(context)!.getStarted,
                        
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}
