import 'package:medicinedocter/model/med_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:medicinedocter/db/med_db.dart';
import 'package:medicinedocter/pages/Med.dart';
import 'package:medicinedocter/pages/started.dart';

class FormScreen extends StatelessWidget {
 
  final formkey = GlobalKey<FormState>();
  late MedsDatabase _db;
  final titlecontroller = TextEditingController();
  final datacontroller = TextEditingController();

  Future<void> newBook(String title, String data) async {
    _db = MedsDatabase.instance;
    Med med = Med(
      med_id: 0,
      title: title,
      data: data,
    );
    Med new_med = await _db.create(med); // ทำคำสั่งเพิ่มข้อมูลใหม่
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.addMedicineForm),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: formkey,
            child: Column(
              children: [
                
                TextFormField(
                  decoration: new InputDecoration(labelText: AppLocalizations.of(context)!.name),
                  
                  autofocus: true,
                  controller: titlecontroller,
                  validator: (str) {
                    if (str!.isEmpty) {
                      return "Please insert Data";
                    }
                    return null;
                  },
                ),
                SizedBox(
                          height: 5,
                        ),
                TextFormField(
                  decoration: new InputDecoration(labelText: AppLocalizations.of(context)!.data),
                  controller: datacontroller,
                  maxLines: 6,
                ),
                SizedBox(
                          height: 5,
                        ),
                TextButton(
                   
                  child: Text(AppLocalizations.of(context)!.add),
                  onPressed: () async {
                    if (formkey.currentState!.validate()) {
                      var title = titlecontroller.text;
                      var data = datacontroller.text;

                      newBook(title, data);
                      
                    
                    Navigator.pushNamedAndRemoveUntil(context, '/homepage', ModalRoute.withName('/home'));
                    }
                  },
                )
              ],
            ),
            
          ),
        ));
  }
}
