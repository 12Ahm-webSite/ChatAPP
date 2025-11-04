import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // إرسال رسالة جديدة
  Future<void> sendMessage(String receiverId, String text) async {
    try {
      await _supabase.from('messages').insert({
        'sender_id': _supabase.auth.currentUser!.id,
        'receiver_id': receiverId,
        'text': text,
        'message_type': 'text',
      });
    } catch (e) {
      print('خطأ في إرسال الرسالة: $e');
    }
  }

  // الحصول على المحادثات في الوقت الحقيقي
  Stream<List<Message>> getMessages(String user1Id, String user2Id) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((list) {
          // تصفية الرسائل يدوياً
          return list
              .where((message) {
                final sender = message['sender_id'];
                final receiver = message['receiver_id'];
                return (sender == user1Id && receiver == user2Id) ||
                    (sender == user2Id && receiver == user1Id);
              })
              .map((json) => _messageFromJson(json))
              .toList();
        });
  }

  // الحصول على قائمة المحادثات
  Future<List<Map<String, dynamic>>> getChats(String currentUserId) async {
    try {
      // جلب آخر رسالة من كل محادثة
      final response = await _supabase
          .from('messages')
          .select('*')
          .order('created_at', ascending: false);

      // تجميع المحادثات
      final Map<String, Map<String, dynamic>> chatsMap = {};

      for (var message in response) {
        final senderId = message['sender_id'];
        final receiverId = message['receiver_id'];

        // التحقق إذا كانت الرسالة متعلقة بالمستخدم الحالي
        if (senderId == currentUserId || receiverId == currentUserId) {
          final otherUserId = senderId == currentUserId ? receiverId : senderId;

          if (!chatsMap.containsKey(otherUserId)) {
            try {
              // جلب اسم المستخدم الآخر
              final userResponse = await _supabase
                  .from('users')
                  .select('username')
                  .eq('id', otherUserId)
                  .single();

              chatsMap[otherUserId] = {
                'id': otherUserId,
                'name': userResponse['username'] ?? 'مستخدم',
                'lastMessage': message['text'],
                'time': _formatTime(DateTime.parse(message['created_at'])),
                'unread':
                    await _countUnreadMessages(currentUserId, otherUserId),
              };
            } catch (e) {
              print('خطأ في جلب بيانات المستخدم $otherUserId: $e');
            }
          }
        }
      }

      return chatsMap.values.toList();
    } catch (e) {
      print('خطأ في جلب المحادثات: $e');
      return [];
    }
  }

  // الحصول على قائمة المستخدمين المتاحين
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final currentUserId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('users')
          .select('id, username, email')
          .neq('id', currentUserId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('خطأ في جلب المستخدمين: $e');
      return [];
    }
  }

  // بديل أبسط لجلب المحادثات
  Future<List<Map<String, dynamic>>> getChatsSimple(
      String currentUserId) async {
    try {
      // جلب جميع المستخدمين عدا الحالي
      final users = await getUsers();

      // إضافة معلومات المحادثة لكل مستخدم
      for (var user in users) {
        final lastMessage = await _getLastMessage(currentUserId, user['id']);
        user['lastMessage'] = lastMessage?['text'] ?? 'بدء محادثة جديدة';
        user['time'] = lastMessage != null
            ? _formatTime(DateTime.parse(lastMessage['created_at']))
            : 'لم يتحدث بعد';
        user['unread'] = 0;
      }

      return users;
    } catch (e) {
      print('خطأ في جلب المحادثات المبسطة: $e');
      return [];
    }
  }

  // جلب آخر رسالة بين مستخدمين
  Future<Map<String, dynamic>?> _getLastMessage(
      String user1Id, String user2Id) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*')
          .or('and(sender_id.eq.$user1Id,receiver_id.eq.$user2Id),and(sender_id.eq.$user2Id,receiver_id.eq.$user1Id)')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  // دالات مساعدة
  Message _messageFromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      text: json['text'] ?? '',
      type: _parseMessageType(json['message_type']),
      timestamp: DateTime.parse(json['created_at']),
    );
  }

  MessageType _parseMessageType(String typeString) {
    if (typeString.contains('image')) return MessageType.image;
    if (typeString.contains('audio')) return MessageType.audio;
    return MessageType.text;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} أيام';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعات';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقائق';
    } else {
      return 'الآن';
    }
  }

  Future<int> _countUnreadMessages(
      String currentUserId, String otherUserId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('id')
          .eq('sender_id', otherUserId)
          .eq('receiver_id', currentUserId);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  // حذف المحادثة
  Future<void> deleteChat(String user1Id, String user2Id) async {
    try {
      await _supabase.from('messages').delete().or(
          'and(sender_id.eq.$user1Id,receiver_id.eq.$user2Id),and(sender_id.eq.$user2Id,receiver_id.eq.$user1Id)');
    } catch (e) {
      print('خطأ في حذف المحادثة: $e');
    }
  }
}
