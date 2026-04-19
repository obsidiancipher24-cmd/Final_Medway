import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Dialog for updating weight
class WeightForm extends StatelessWidget {
  final String initialWeight;
  final String docId;

  const WeightForm({
    super.key,
    required this.initialWeight,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController weightController = TextEditingController(
      text: initialWeight,
    );

    return AlertDialog(
      title: const Text('Update Weight'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 100,
            maxHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight (lbs)',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final weight = weightController.text.trim();
            if (weight.isEmpty ||
                double.tryParse(weight) == null ||
                double.parse(weight) <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid positive number'),
                ),
              );
              return;
            }
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(docId)
                  .collection('health_info')
                  .doc('data')
                  .set({
                    'weight': weight,
                    'lastUpdated': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating weight: $e')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Dialog for updating blood group
class BloodGroupForm extends StatefulWidget {
  final String initialBloodGroup;
  final String docId;

  const BloodGroupForm({
    super.key,
    required this.initialBloodGroup,
    required this.docId,
  });

  @override
  _BloodGroupFormState createState() => _BloodGroupFormState();
}

class _BloodGroupFormState extends State<BloodGroupForm> {
  final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  String? selectedBloodGroup;

  @override
  void initState() {
    super.initState();
    selectedBloodGroup = widget.initialBloodGroup;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Blood Group'),
      content: DropdownButton<String>(
        value: selectedBloodGroup,
        isExpanded: true,
        hint: const Text('Select Blood Group'),
        items:
            bloodGroups.map((String bloodGroup) {
              return DropdownMenuItem<String>(
                value: bloodGroup,
                child: Text(bloodGroup),
              );
            }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedBloodGroup = newValue;
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (selectedBloodGroup == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a blood group')),
              );
              return;
            }
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.docId)
                  .collection('health_info')
                  .doc('data')
                  .set({
                    'bloodGroup': selectedBloodGroup,
                    'lastUpdated': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating blood group: $e')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
