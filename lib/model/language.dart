class Language{
final  int id ;
final String flag ;
final String name ;
final String languageCode ;

Language(this.id,this.flag,this.name,this.languageCode);

static List<Language> languageList(){
  return <Language>[
    Language(1, "1.", "English","en"),
    Language(2, "2.", "ไทย", "th"),
    Language(3, "3.", "ខ្មែរ", "kh"),
    Language(4, "4.", "မြန်မာ", "mm"),
    Language(5, "5.", "Việt Nam", "vn"),
  ];
}
}