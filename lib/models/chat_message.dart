import 'dart:convert';

ChatMessageModel chatMessageModelFromJson(String str) =>
    ChatMessageModel.fromJson(json.decode(str));

String chatMessageModelToJson(ChatMessageModel data) =>
    json.encode(data.toJson());

class ChatMessageModel {
  int chatId;
  String message;
  bool fromMe;

  ChatMessageModel({
    this.chatId,
    this.message,
    this.fromMe
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        chatId: json["chat_id"],
        message: json["message"],
        fromMe: json["fromMe"]
      );

  Map<String, dynamic> toJson() => {
    "chat_id": chatId,
    "message": message,
    "fromMe": fromMe,
  };
}