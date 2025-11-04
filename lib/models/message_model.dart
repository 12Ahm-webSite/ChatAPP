import 'dart:io';

enum MessageType { text, image, audio }

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final String? localImagePath;
  final String? localAudioPath;
  final MessageType type;
  final DateTime timestamp;
  final bool isSeen;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.localImagePath,
    this.localAudioPath,
    required this.type,
    required this.timestamp,
    this.isSeen = false,
  });

  // إنشاء رسالة نصية
  factory Message.text({
    required String id,
    required String senderId,
    required String receiverId,
    required String text,
  }) {
    return Message(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );
  }

  // إنشاء رسالة صورة
  factory Message.image({
    required String id,
    required String senderId,
    required String receiverId,
    required String imagePath,
    String text = '',
  }) {
    return Message(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      localImagePath: imagePath,
      type: MessageType.image,
      timestamp: DateTime.now(),
    );
  }

  // إنشاء رسالة صوت
  factory Message.audio({
    required String id,
    required String senderId,
    required String receiverId,
    required String audioPath,
    String text = '',
  }) {
    return Message(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      localAudioPath: audioPath,
      type: MessageType.audio,
      timestamp: DateTime.now(),
    );
  }

  // التحقق من وجود مرفقات
  bool get hasImage =>
      localImagePath != null && File(localImagePath!).existsSync();
  bool get hasAudio =>
      localAudioPath != null && File(localAudioPath!).existsSync();

  @override
  String toString() {
    return 'Message(id: $id, type: $type, text: $text, image: $localImagePath, audio: $localAudioPath)';
  }
}
