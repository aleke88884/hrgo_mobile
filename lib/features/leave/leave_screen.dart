import 'package:flutter/material.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _leaveType = 'Annual';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Leave Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start Date'),
            TextField(
              decoration: InputDecoration(
                hintText: 'Select Date',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            Text('End Date'),
            TextField(
              decoration: InputDecoration(
                hintText: 'Select Date',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() {
                    _endDate = date;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            Text('Leave Type'),
            DropdownButtonFormField<String>(
              value: _leaveType,
              items: ['Annual', 'Sick'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _leaveType = newValue!;
                });
              },
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                minimumSize: Size(double.infinity, 50),
              ),
              child: Center(
                child: Text(
                  'Submit Request',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Leave Schedule', style: TextStyle(fontSize: 18)),
            Card(
              child: ListTile(
                title: Text('22.04.2024 - 26.04.2024'),
                trailing: Icon(Icons.face),
                subtitle: Text('Sign with Face ID'),
                onTap: () {},
              ),
            ),
            Card(
              color: Colors.grey[300],
              child: Center(child: Text('Leave approved')),
            ),
          ],
        ),
      ),
    );
  }
}
