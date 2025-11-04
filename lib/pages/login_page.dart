import 'package:flutter/material.dart';
import 'package:chat_app/services/auth_service.dart';
import 'chats_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isLoading = false;
  bool _isRegistering = false;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('الرجاء إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await AuthService().login(email, password);

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatsPage()),
        );
      } else {
        _showError('فشل تسجيل الدخول. تحقق من البيانات');
      }
    } catch (e) {
      _showError('حدث خطأ أثناء تسجيل الدخول');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      _showError('الرجاء ملء جميع الحقول');
      return;
    }

    if (password.length < 6) {
      _showError('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await AuthService().register(username, email, password);

      if (success) {
        _showSuccess('تم إنشاء الحساب بنجاح! يمكنك تسجيل الدخول الآن');
        setState(() => _isRegistering = false);
        _usernameController.clear();
      } else {
        _showError('فشل إنشاء الحساب. قد يكون البريد مستخدم مسبقاً');
      }
    } catch (e) {
      _showError('حدث خطأ أثناء إنشاء الحساب');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _emailController.clear();
      _passwordController.clear();
      _usernameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // العنوان
              Text(
                'تطبيق الدردشة',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 40),

              // حقل اسم المستخدم (يظهر فقط في حالة التسجيل)
              if (_isRegistering) ...[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'اسم المستخدم',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16),
              ],

              // حقل البريد الإلكتروني
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16),

              // حقل كلمة المرور
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 32),

              // زر الدخول أو التسجيل
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : (_isRegistering ? _register : _login),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isRegistering ? 'إنشاء حساب' : 'دخول',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
              SizedBox(height: 16),

              // زر التبديل بين التسجيل والدخول
              TextButton(
                onPressed: _isLoading ? null : _toggleMode,
                child: Text(
                  _isRegistering
                      ? 'لديك حساب؟ سجل الدخول'
                      : 'لا تملك حساب؟ إنشاء حساب جديد',
                ),
              ),

              // بيانات تجريبية (للتطوير فقط)
              if (!_isRegistering) ...[
                SizedBox(height: 20),
                Text(
                  'بيانات تجريبية:',
                  style: TextStyle(color: Colors.grey),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        _emailController.text = 'user1@test.com';
                        _passwordController.text = '123456';
                      },
                      child: Text('حساب 1'),
                    ),
                    TextButton(
                      onPressed: () {
                        _emailController.text = 'user2@test.com';
                        _passwordController.text = '123456';
                      },
                      child: Text('حساب 2'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
