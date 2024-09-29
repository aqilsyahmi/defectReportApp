import 'package:flutter/material.dart';
import 'google_sheets_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Defect Report App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DefectReportForm(),
    ); 
  }
}

class DefectReportForm extends StatefulWidget {
  const DefectReportForm({Key? key}) : super(key: key);

  @override
  _DefectReportFormState createState() => _DefectReportFormState();
}

class _DefectReportFormState extends State<DefectReportForm> {
  final List<DefectEntry> _defects = [DefectEntry()];
  final GoogleSheetsService _sheetsService = GoogleSheetsService();

  void _addDefect() {
    setState(() {
      _defects.add(DefectEntry());
    });
  }

  void _resetForm() {
    setState(() {
      _defects.clear();
      _defects.add(DefectEntry());
    });
  }

  Future<void> _submitReport() async {
    try {
      final defectData = _defects.map((defect) => {
        'id': defect.idController.text,
        'location': defect.locationController.text,
        'description': defect.descriptionController.text,
      }).toList();

      const spreadsheetId = '1WPt7W1iLgCTf4RGos_olrC6ARo7jDNYUQLYtRsXErI0';

      await _sheetsService.submitDefectReport(defectData, spreadsheetId);

      // Show success dialog
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Report submitted successfully!'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      // Reset the form
      _resetForm();
    } catch (e) {
      print('Error in _submitReport: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Defect Report'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Defect Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ..._defects.map((defect) => DefectEntryForm(defect: defect)),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addDefect,
                icon: Icon(Icons.add),
                label: Text('Add Another Defect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitReport,
                child: Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DefectEntry {
  final TextEditingController idController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
}

class DefectEntryForm extends StatelessWidget {
  final DefectEntry defect;

  const DefectEntryForm({Key? key, required this.defect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: defect.idController,
              decoration: const InputDecoration(labelText: 'Defect ID'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: defect.locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: defect.descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
    );
  }
}