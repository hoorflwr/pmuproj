import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/connection_service.dart';
import 'chat_screen.dart';

class ConnectedMentorsScreen extends StatefulWidget {
  const ConnectedMentorsScreen({Key? key}) : super(key: key);

  @override
  _ConnectedMentorsScreenState createState() => _ConnectedMentorsScreenState();
}

class _ConnectedMentorsScreenState extends State<ConnectedMentorsScreen> {
  final ConnectionService _connectionService = ConnectionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getConnectedMentors() {
    return _firestore
        .collection('connections')
        .where('menteeId', isEqualTo: _auth.currentUser?.uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Mentors'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getConnectedMentors(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No connected mentors yet.\nTry finding mentors in the Find Mentors section!',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final connection = snapshot.data!.docs[index];
              final mentorId = connection['mentorId'] as String;

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(mentorId).get(),
                builder: (context, mentorSnapshot) {
                  if (!mentorSnapshot.hasData) {
                    return const ListTile(
                      leading: CircularProgressIndicator(),
                    );
                  }

                  final mentorData = {
                    'id': mentorSnapshot.data!.id,
                    ...mentorSnapshot.data!.data() as Map<String, dynamic>
                  };

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          mentorData['username'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        mentorData['username'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mentorData['email']),
                          if (mentorData['expertise'] != null)
                            Text('Expertise: ${mentorData['expertise']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat),
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                otherUser: mentorData,
                              ),
                            ),
                          );
                        },
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
