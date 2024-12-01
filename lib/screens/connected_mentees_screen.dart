import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/connection_service.dart';
import 'chat_screen.dart';

class ConnectedMenteesScreen extends StatefulWidget {
  const ConnectedMenteesScreen({Key? key}) : super(key: key);

  @override
  _ConnectedMenteesScreenState createState() => _ConnectedMenteesScreenState();
}

class _ConnectedMenteesScreenState extends State<ConnectedMenteesScreen> {
  final ConnectionService _connectionService = ConnectionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getConnectedMentees() {
    return _firestore
        .collection('connections')
        .where('mentorId', isEqualTo: _auth.currentUser?.uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Mentees'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getConnectedMentees(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No connected mentees yet'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final connection = snapshot.data!.docs[index];
              final menteeId = connection['menteeId'] as String;

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(menteeId).get(),
                builder: (context, menteeSnapshot) {
                  if (!menteeSnapshot.hasData) {
                    return const ListTile(
                      leading: CircularProgressIndicator(),
                    );
                  }

                  final menteeData = {
                    'id': menteeSnapshot.data!.id,
                    ...menteeSnapshot.data!.data() as Map<String, dynamic>
                  };

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(menteeData['username'][0].toUpperCase()),
                    ),
                    title: Text(menteeData['username']),
                    subtitle: Text(menteeData['email']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chat),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  otherUser: menteeData,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
