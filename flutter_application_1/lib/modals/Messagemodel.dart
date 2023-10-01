class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;
  int? unreadCount;

  MessageModel(
      {this.messageid,
      this.sender,
      this.text,
      this.seen,
      this.createdon,
      this.unreadCount = 0});
  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"].toDate();
    unreadCount = map["unreadCount"];

  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon,
      "unreadCount": unreadCount,
    };
  }
}
