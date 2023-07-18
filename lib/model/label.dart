class Label {
  final int? id;
  final String title;

  const Label({this.id, required this.title});
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    return map;
  }

  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(id: map['id'], title: map['title']);
  }
}
