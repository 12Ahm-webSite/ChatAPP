import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://egxbnjtknxrkksywgrac.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVneGJuanRrbnhya2tzeXdncmFjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyNjM0OTMsImV4cCI6MjA3NzgzOTQ5M30.88TaMU7SPqcV-bl6slAb4Lfm3wjOvWJNDnR5gYuMpyQ',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق الدردشة',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'HUHere',
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
