class AlarmInfo {
  int? id;
  String? title;
  DateTime? alarmDateTime;
  String? dateRange;
  bool? isPending;
  int? gradientColorIndex;

  AlarmInfo(
      {this.id,
      this.title,
      this.dateRange,
      this.alarmDateTime,
      this.isPending,
      this.gradientColorIndex});

  factory AlarmInfo.fromMap(Map<String, dynamic> json) => AlarmInfo(
        id: json["id"],
        title: json["title"],
        dateRange: json["dateRange"],
        alarmDateTime: DateTime.parse(json["alarmDateTime"]),
        isPending: json["isPending"],
        gradientColorIndex: json["gradientColorIndex"],
      );
  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "dateRange":dateRange,
        "alarmDateTime": alarmDateTime!.toIso8601String(),
        "isPending": isPending,
        "gradientColorIndex": gradientColorIndex,
      };
}
