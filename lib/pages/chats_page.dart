import 'package:flutter/material.dart';
import 'chat_page.dart';

class ChatsPage extends StatefulWidget {
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'name': 'أحمد',
      'lastMessage': 'مرحبا! كيف الحال؟',
      'time': '10:30 ص',
      'unread': 2,
    },
    {
      'id': '2',
      'name': 'محمد',
      'lastMessage': 'شكراً على المساعدة',
      'time': 'أمس',
      'unread': 0,
    },
    {
      'id': '3',
      'name': 'فاطمة',
      'lastMessage': 'صورتك جميلة 👍',
      'time': 'الجمعة',
      'unread': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المحادثات'),
        actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                chat['name'][0],
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(chat['name']),
            subtitle: Text(chat['lastMessage']),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  chat['time'],
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (chat['unread'] > 0) ...[
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chat['unread'].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    currentUserId: 'user1',
                    otherUserId: chat['id'],
                    otherUserName: chat['name'],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // إضافة محادثة جديدة
        },
        child: Icon(Icons.chat),
      ),
    );
  }
}
