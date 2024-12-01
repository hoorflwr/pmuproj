import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class MentorProfileScreen extends StatefulWidget {
  const MentorProfileScreen({Key? key}) : super(key: key);

  @override
  _MentorProfileScreenState createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  bool isEditing = false;

  String username = '';
  String email = '';
  String bio = '';
  List<String> expertise = [];
  String expertiseString = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_auth.currentUser != null) {
      try {
        final userData = await _auth.getUserProfile(_auth.currentUser!.uid);
        if (userData != null) {
          setState(() {
            username = userData['username'] ?? '';
            email = userData['email'] ?? '';
            bio = userData['bio'] ?? '';
            expertise = List<String>.from(userData['expertise'] ?? []);
            expertiseString = expertise.join(', ');
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error loading profile: $e');
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await _auth.updateMentorProfile(
          uid: _auth.currentUser!.uid,
          username: username,
          bio: bio,
          expertise: expertiseString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        );
        setState(() {
          isEditing = false;
          isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() => isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _updateProfile();
              } else {
                setState(() => isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              if (isEditing) ...[
                TextFormField(
                  initialValue: username,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter a username' : null,
                  onChanged: (val) => setState(() => username = val),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: bio,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (val) => val!.isEmpty ? 'Enter a bio' : null,
                  onChanged: (val) => setState(() => bio = val),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: expertiseString,
                  decoration: const InputDecoration(
                    labelText: 'Areas of Expertise (comma separated)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (val) => val!.isEmpty ? 'Enter your areas of expertise' : null,
                  onChanged: (val) => setState(() => expertiseString = val),
                ),
              ] else ...[
                ListTile(
                  title: const Text('Username'),
                  subtitle: Text(username),
                ),
                ListTile(
                  title: const Text('Email'),
                  subtitle: Text(email),
                ),
                ListTile(
                  title: const Text('Bio'),
                  subtitle: Text(bio),
                ),
                const ListTile(
                  title: Text('Areas of Expertise'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8.0,
                    children: expertise.map((area) => Chip(
                      label: Text(area),
                      backgroundColor: Colors.blue.shade100,
                    )).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
