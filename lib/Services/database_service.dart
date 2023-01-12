import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});

  // Reference Collections:
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final groupsCollection = FirebaseFirestore.instance.collection('groups');

  // Saving the UserData:
  Future savingUsersData(String fullName, String email) async {
    return await usersCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  // Getting the UserData:
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await usersCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }

  // Getting the User Groups:
  getUsersGroup() async {
    return usersCollection.doc(uid).snapshots();
  }

  // Creating a Group:
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupsCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    // Update the member:
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = usersCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  // Getting the Chats:
  getChats(String groupId) async {
    return groupsCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupsCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  // Getting group Members:
  getGroupMembers(groupId) async {
    return groupsCollection.doc(groupId).snapshots();
  }

  // Search:
  searchByName(String groupName) {
    return groupsCollection.where('groupName', isEqualTo: groupName).get();
  }
}
