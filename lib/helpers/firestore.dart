import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do/auth/google.dart';
import 'package:to_do/model/firestore.dart';

class FireStoreHelper {
  static final FireStoreHelper instance = FireStoreHelper._instance();
  FireStoreHelper._instance();
  FirebaseFirestore db = FirebaseFirestore.instance;
  static String? docId;

  Future<DocumentReference> insertUserDataOnFireStore(UserData userData) async {
    DocumentReference refrence =
        await db.collection('users').add(userData.toMap());
    return refrence;
  }

  Future<void> saveUseDataOnFireStore(
      String uid, String email, UserData userData) async {
    if (docId == null) {
      UserData? user = await getUserDataOnFireStore(uid, email);
      if (user == null) {
        await insertUserDataOnFireStore(userData);
        return;
      }
    }
    await db.collection('users').doc(docId).update(userData.toMap());
  }

  Future<UserData?> getUserDataOnFireStore(String uid, String email) async {
    QuerySnapshot<Map<String, dynamic>> query =
        await db.collection('users').where('uid', isEqualTo: uid).get();
    if (query.size != 0) {
      docId = query.docs[0].id;
      return UserData.fromMap(query.docs[0].data());
    }
    return null;
  }
}
