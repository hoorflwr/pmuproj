import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';

class CreateEventScreen extends StatefulWidget {
  final String? eventId;
  final bool isEditing;

  const CreateEventScreen({
    Key? key,
    this.eventId,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _capacityController;
  late TextEditingController _meetingLinkController;

  DateTime _selectedDateTime = DateTime.now();
  bool _isVirtual = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _capacityController = TextEditingController();
    _meetingLinkController = TextEditingController();

    if (widget.isEditing) {
      _loadEventData();
    }
  }

  Future<void> _loadEventData() async {
    setState(() => _isLoading = true);
    try {
      final eventDoc = await _eventService.getEventDetails(widget.eventId!);
      final eventData = eventDoc.data() as Map<String, dynamic>;

      _titleController.text = eventData['title'];
      _descriptionController.text = eventData['description'];
      _locationController.text = eventData['location'];
      _capacityController.text = eventData['capacity'].toString();
      _meetingLinkController.text = eventData['meetingLink'] ?? '';
      _isVirtual = eventData['isVirtual'];
      _selectedDateTime = (eventData['dateTime'] as Timestamp).toDate();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading event: $e')),
      );
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (widget.isEditing) {
          await _eventService.updateEvent(
            eventId: widget.eventId!,
            title: _titleController.text,
            description: _descriptionController.text,
            dateTime: _selectedDateTime,
            location: _locationController.text,
            isVirtual: _isVirtual,
            capacity: int.parse(_capacityController.text),
            meetingLink: _isVirtual ? _meetingLinkController.text : null,
          );
        } else {
          await _eventService.createEvent(
            mentorId: _authService.currentUser!.uid,
            title: _titleController.text,
            description: _descriptionController.text,
            dateTime: _selectedDateTime,
            location: _locationController.text,
            isVirtual: _isVirtual,
            capacity: int.parse(_capacityController.text),
            meetingLink: _isVirtual ? _meetingLinkController.text : null,
          );
        }

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'Event updated' : 'Event created'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && widget.isEditing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Event' : 'Create Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date and Time'),
                subtitle: Text(
                  '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} at ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDateTime,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Virtual Event'),
                value: _isVirtual,
                onChanged: (value) => setState(() => _isVirtual = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: _isVirtual ? 'Platform' : 'Location',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'This field is required' : null,
              ),
              if (_isVirtual) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _meetingLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Meeting Link',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter meeting link' : null,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter capacity';
                  }
                  final number = int.tryParse(value!);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(widget.isEditing ? 'Update Event' : 'Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }
}
