import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

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

  // ─── Google Sign In ──────────────────────────────────────────────────────────
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Kiểm tra xem user đã tồn tại trong Firestore chưa
        final userDoc = await _db.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          // Nếu chưa, tạo document mới
          final newUser = UserModel(
            id: user.uid,
            email: user.email ?? '',
            fullName: user.displayName ?? 'Người dùng Google',
            phone: user.phoneNumber ?? '',
          );
          await _db.collection('users').doc(user.uid).set(newUser.toMap());
          return newUser;
        }
        return UserModel.fromMap(userDoc.data()!, user.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Đăng nhập bằng Google thất bại: $e');
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
      // 1. Kiểm tra xem email có tồn tại trong hệ thống (Firestore) không
      final users = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (users.docs.isEmpty) {
        throw Exception('Email này chưa được đăng ký trong hệ thống.');
      }

      // 2. Nếu tồn tại, mới gọi Firebase gửi mail
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('DEBUG: Firebase Auth Error Code: ${e.code}');
      throw Exception(_authErrorMessage(e.code));
    } catch (e) {
      print('DEBUG: General Reset Error: $e');
      if (e is Exception) rethrow;
      throw Exception('Gửi email đặt lại mật khẩu thất bại. Vui lòng thử lại.');
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
