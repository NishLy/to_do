import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do/auth/google.dart';

class AccountHelper {
  static final AccountHelper instance = AccountHelper._instance();
  AccountHelper._instance();
  User? user;

  setUserData(User? user) {
    this.user = user;
  }

  Future<User?> getUserData() async {
    user ??= await Authentication.getUser();
    return user;
  }
}
