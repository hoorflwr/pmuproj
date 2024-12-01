import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get chat room ID (sorted user IDs to ensure consistency)
  String getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); // Sort to ensure same room ID regardless of order
    return ids.join('_');
  }

  // Send message
  Future<void> sendMessage({
    required String receiverId,
    required String message,
    String? imageUrl,
  }) async {
    final senderId = _auth.currentUser?.uid;
    if (senderId == null) return;

    final chatRoomId = getChatRoomId(senderId, receiverId);
    final timestamp = ServerValue.timestamp;

    final messageData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };

    await _database
        .ref()
        .child('chats')
        .child(chatRoomId)
        .child('messages')
        .push()
        .set(messageData);

    // Update last message for chat list
    await _database.ref().child('chats').child(chatRoomId).update({
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'participants': {
        senderId: true,
        receiverId: true,
      },
    });
  }

  // Get chat messages stream
  Stream<DatabaseEvent> getChatMessages(String otherUserId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return const Stream.empty();

    final chatRoomId = getChatRoomId(currentUserId, otherUserId);
    return _database
        .ref()
        .child('chats')
        .child(chatRoomId)
        .child('messages')
        .orderByChild('timestamp')
        .onValue;
  }

  // Get chat list stream (recent conversations)
  Stream<DatabaseEvent> getChatList() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return const Stream.empty();

    return _database
        .ref()
        .child('chats')
        .orderByChild('participants/$currentUserId')
        .equalTo(true)
        .onValue;
  }

  // Get user details from Firestore
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return {'id': doc.id, ...doc.data()!};
    }
    return null;
  }
}
