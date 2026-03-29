import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';

@singleton
class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DioClient dioClient;

  GoogleAuthService(this.dioClient);

  Future<GoogleAuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const GoogleAuthResult.failure('Đăng nhập Google bị hủy');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return const GoogleAuthResult.failure(
          'Không lấy được user từ Firebase',
        );
      }

      // Lấy Firebase ID token gửi lên BE
      final idToken = await firebaseUser.getIdToken();

      // Gửi lên Node.js — BE verify và trả JWT
      final res = await dioClient.dio.post(
        '/auth/google',
        data: {'idToken': idToken},
      );

      // Lưu JWT token giống login thường
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', res.data['token']);
      await prefs.setString('user_name', firebaseUser.displayName ?? '');
      await prefs.setString('user_email', firebaseUser.email ?? '');
      await prefs.setString('user_avatar', firebaseUser.photoURL ?? '');
      await prefs.setString('login_type', 'google');

      return const GoogleAuthResult.success();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'BE từ chối đăng nhập';
      return GoogleAuthResult.failure(msg);
    } catch (e) {
      return GoogleAuthResult.failure(e.toString());
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  User? get currentUser => _auth.currentUser;
}

class GoogleAuthResult {
  final bool success;
  final String? message;

  const GoogleAuthResult.success() : success = true, message = null;
  const GoogleAuthResult.failure(this.message) : success = false;
}
