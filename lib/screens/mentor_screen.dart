import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pmu_mentor/main.dart';
import 'event_management_screen.dart';
import 'connection_requests_screen.dart';
import 'connected_mentees_screen.dart';
import 'chat_list_screen.dart';
import 'mentor_profile_screen.dart';

class MentorScreen extends StatefulWidget {
  const MentorScreen({Key? key}) : super(key: key);

  @override
  _MentorScreenState createState() => _MentorScreenState();
}

class _MentorScreenState extends State<MentorScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => AuthWrapper(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDashboardCard(
              'Profile',
              'Update your profile information',
              Icons.person,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MentorProfileScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              'Events',
              'Manage your events',
              Icons.event,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventManagementScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              'Connection Requests',
              'View and manage mentee requests',
              Icons.person_add,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConnectionRequestsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              'Connected Mentees',
              'View your connected mentees',
              Icons.people,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConnectedMenteesScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              'Messages',
              'Chat with your mentees',
              Icons.chat,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatListScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
