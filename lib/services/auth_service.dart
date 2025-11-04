import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // تسجيل الدخول
  Future<bool> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      print('خطأ في تسجيل الدخول: $e');
      return false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn() async {
    return _supabase.auth.currentUser != null;
  }

  // الحصول على المستخدم الحالي
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      // جلب بيانات المستخدم من جدول users
      final response = await _supabase
          .from('users')
          .select('id, username, email')
          .eq('id', user.id)
          .single();

      return response;
    }
    return null;
  }

  // إنشاء حساب جديد
  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // إضافة المستخدم للجدول
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'username': username,
        });
        return true;
      }
      return false;
    } catch (e) {
      print('خطأ في إنشاء الحساب: $e');
      return false;
    }
  }

  // الحصول على ID المستخدم الحالي
  String? get currentUserId => _supabase.auth.currentUser?.id;
}
