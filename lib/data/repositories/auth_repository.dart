import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // ─── EmailJS config ─────────────────────────────────────────────────────────
  // Tạo account miễn phí tại https://www.emailjs.com rồi điền vào đây
  static const _emailJsServiceId  = 'YOUR_SERVICE_ID';
  static const _emailJsTemplateId = 'YOUR_TEMPLATE_ID';
  static const _emailJsPublicKey  = 'YOUR_PUBLIC_KEY';

  // ─── Login ──────────────────────────────────────────────────────────────────
  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return null;
      return await _fetchUserDoc(uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e.code));
    } catch (e) {
      throw Exception('Đăng nhập thất bại. Vui lòng thử lại.');
    }
  }

  // ─── Register ───────────────────────────────────────────────────────────────
  Future<UserModel?> register(
    String email,
    String password,
    String fullName,
    String phone,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return null;

      final user = UserModel(
        id: uid,
        email: email,
        fullName: fullName,
        phone: phone,
      );
      await _db.collection('users').doc(uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e.code));
    } catch (e) {
      throw Exception('Đăng ký thất bại. Vui lòng thử lại.');
    }
  }

  // ─── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Đăng xuất thất bại. Vui lòng thử lại.');
    }
  }

  // ─── Reset password (Firebase link) ─────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e.code));
    } catch (e) {
      throw Exception('Gửi email đặt lại mật khẩu thất bại. Vui lòng thử lại.');
    }
  }

  // ─── Send OTP ────────────────────────────────────────────────────────────────
  /// Tạo mã 6 số, lưu Firestore (hết hạn sau 10 phút), gửi qua EmailJS.
  Future<void> sendOtp(String email) async {
    try {
      // Kiểm tra email tồn tại trong users collection
      final users = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (users.docs.isEmpty) {
        throw Exception('Không tìm thấy tài khoản với email này.');
      }

      // Gen 6 chữ số ngẫu nhiên
      final code = (100000 + Random().nextInt(900000)).toString();
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      // Lưu vào Firestore
      await _db.collection('otp_codes').doc(email).set({
        'code': code,
        'expiresAt': Timestamp.fromDate(expiresAt),
      });

      // Gửi email qua EmailJS
      await _sendEmailJs(email: email, code: code);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e.code));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gửi mã OTP thất bại. Vui lòng thử lại.');
    }
  }

  // ─── Verify OTP ─────────────────────────────────────────────────────────────
  /// Trả về `true` nếu code đúng và chưa hết hạn, xoá record sau khi verify.
  Future<bool> verifyOtp(String email, String code) async {
    try {
      final doc = await _db.collection('otp_codes').doc(email).get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('Mã OTP không tồn tại. Vui lòng yêu cầu gửi lại.');
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String? ?? '';
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiresAt)) {
        await _db.collection('otp_codes').doc(email).delete();
        throw Exception('Mã OTP đã hết hạn. Vui lòng yêu cầu gửi lại.');
      }

      if (storedCode != code) {
        return false; // Sai code — cho phép retry
      }

      // Xoá OTP sau khi dùng
      await _db.collection('otp_codes').doc(email).delete();
      return true;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Xác minh OTP thất bại. Vui lòng thử lại.');
    }
  }

  // ─── Get current user ────────────────────────────────────────────────────────
  Future<UserModel?> getCurrentUser() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;
      return await _fetchUserDoc(uid);
    } catch (e) {
      throw Exception('Không thể lấy thông tin người dùng. Vui lòng thử lại.');
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  Future<UserModel?> _fetchUserDoc(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  Future<void> _sendEmailJs({
    required String email,
    required String code,
  }) async {
    const url = 'https://api.emailjs.com/api/v1.0/email/send';
    final body = jsonEncode({
      'service_id':  _emailJsServiceId,
      'template_id': _emailJsTemplateId,
      'user_id':     _emailJsPublicKey,
      'template_params': {
        'to_email': email,
        'otp_code': code,
      },
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể gửi email. Vui lòng thử lại.');
    }
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng dùng ít nhất 6 ký tự.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
      default:
        return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }
}
