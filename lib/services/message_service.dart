import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================================
  // 1. SEND A CONNECTION REQUEST
  // ==========================================
  Future<void> sendConnectionRequest(String receiverId) async {
    final String currentUserId = _auth.currentUser!.uid;

    // Check if request already exists to prevent spam
    final existingRequest = await _firestore
        .collection('requests')
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: receiverId)
        .get();

    if (existingRequest.docs.isEmpty) {
      await _firestore.collection('requests').add({
        'senderId': currentUserId,
        'receiverId': receiverId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // ==========================================
  // 2. GET INCOMING PENDING REQUESTS
  // ==========================================
  Stream<QuerySnapshot> getIncomingRequests() {
    final String currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('requests')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ==========================================
  // 3. RESPOND TO A REQUEST (ACCEPT / DECLINE)
  // ==========================================
  Future<void> respondToRequest(
    String requestId,
    String senderId,
    bool accept,
  ) async {
    final String currentUserId = _auth.currentUser!.uid;

    // 1. Update the request status
    await _firestore.collection('requests').doc(requestId).update({
      'status': accept ? 'accepted' : 'declined',
      'actionTime': FieldValue.serverTimestamp(),
    });

    // 2. If accepted, create a unique Chat Room for these two users
    if (accept) {
      // Sort the UIDs alphabetically to ensure the room ID is always the exact same
      // no matter who is the sender or receiver.
      List<String> ids = [currentUserId, senderId];
      ids.sort();
      String chatRoomId = ids.join('_');

      // Check if room exists, if not, create it
      final roomRef = _firestore.collection('chat_rooms').doc(chatRoomId);
      final roomDoc = await roomRef.get();

      if (!roomDoc.exists) {
        await roomRef.set({
          'users': [currentUserId, senderId], // Array to easily query later
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': 'You are now connected!',
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // ==========================================
  // 4. GET ACTIVE CHAT ROOMS FOR CURRENT USER
  // ==========================================
  Stream<QuerySnapshot> getUserChats() {
    final String currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('chat_rooms')
        .where('users', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
  // ==========================================
  // 5. CREATE A GROUP CHAT ROOM
  // ==========================================
  Future<String> createGroupChat(String groupName, List<String> selectedUserIds) async {
    final String currentUserId = _auth.currentUser!.uid;

    // Include the creator in the group members array
    List<String> allMembers = [...selectedUserIds, currentUserId];

    // Create a new document in chat_rooms collection
    DocumentReference roomRef = await _firestore.collection('chat_rooms').add({
      'isGroup': true,
      'groupName': groupName,
      'groupAdmin': currentUserId,
      'users': allMembers,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': 'Group created by you',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return roomRef.id;
  }
}
