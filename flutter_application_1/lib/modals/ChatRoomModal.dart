import 'Messagemodel.dart';

class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;
  List<MessageModel>? messages;
  Map<String, bool>? readStatus;

  ChatRoomModel(
      {this.messages, this.chatroomid, this.participants, this.lastMessage});
  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastMessage = map["lastmessage"];
    messages = map["mesaages"];
  }
  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastmessage": lastMessage,
      "message": messages,
    };
  }
}
