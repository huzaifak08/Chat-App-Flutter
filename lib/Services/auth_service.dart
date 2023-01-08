import 'package:chat_app/Helper/helper_function.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'database_service.dart';

class AuthService {
  final auth = FirebaseAuth.instance;

  // Login:

  Future logInWithEmailAndPassword(String email, String password) async {
    try {
      User user = (await auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Register:
  Future registerWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      User user = (await auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        // Call our Database Service to Update the User Data:
        await DatabaseService(uid: user.uid).savingUsersData(fullName, email);

        return true;
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      return e.message;
    }
  }

  // Logout:

  Future signOut() async {
    try {
      await HelperFunction.saveUserLoggedInStatus(false);
      await HelperFunction.saveUserEmailSF('');
      await HelperFunction.saveUserNameSF('');

      await auth.signOut();
    } catch (e) {
      return null;
    }
  }
}
