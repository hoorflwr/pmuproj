import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/connection_service.dart';
import '../services/auth_service.dart';

class ConnectionRequestsScreen extends StatefulWidget {
  const ConnectionRequestsScreen({Key? key}) : super(key: key);

  @override
  _ConnectionRequestsScreenState createState() => _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState extends State<ConnectionRequestsScreen> {
  final ConnectionService _connectionService = ConnectionService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _getMenteeData(String menteeId) async {
    DocumentSnapshot menteeDoc = await _firestore.collection('users').doc(menteeId).get();
    return menteeDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connection Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Requests'),
              Tab(text: 'Connected Mentees'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pending Requests Tab
            StreamBuilder<QuerySnapshot>(
              stream: _connectionService.getMentorRequests(_authService.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No pending requests'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final request = snapshot.data!.docs[index];
                    final requestData = request.data() as Map<String, dynamic>;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getMenteeData(requestData['menteeId']),
                      builder: (context, menteeSnapshot) {
                        if (!menteeSnapshot.hasData) {
                          return const SizedBox();
                        }

                        final menteeData = menteeSnapshot.data!;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      child: Text(
                                        menteeData['username'][0].toUpperCase(),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            menteeData['username'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(menteeData['email']),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Message: ${requestData['message']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        await _connectionService
                                            .updateConnectionStatus(
                                          connectionId: request.id,
                                          status: 'rejected',
                                        );
                                      },
                                      child: const Text('Reject'),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await _connectionService
                                            .updateConnectionStatus(
                                          connectionId: request.id,
                                          status: 'accepted',
                                        );
                                      },
                                      child: const Text('Accept'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),

            // Connected Mentees Tab
            StreamBuilder<QuerySnapshot>(
              stream: _connectionService.getMentorMentees(_authService.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No connected mentees'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final connection = snapshot.data!.docs[index];
                    final connectionData = connection.data() as Map<String, dynamic>;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getMenteeData(connectionData['menteeId']),
                      builder: (context, menteeSnapshot) {
                        if (!menteeSnapshot.hasData) {
                          return const SizedBox();
                        }

                        final menteeData = menteeSnapshot.data!;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                menteeData['username'][0].toUpperCase(),
                              ),
                            ),
                            title: Text(menteeData['username']),
                            subtitle: Text(menteeData['email']),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
