class ChatModel {
  String name;
  String icon;
  bool isGroup;
  String time;
  String currentmessage;
  int id;
  ChatModel(
      {required this.name,
      required this.icon,
      required this.isGroup,
      required this.currentmessage,
      required this.time,
      required this.id});
}
