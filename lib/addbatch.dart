import 'package:flutter/material.dart';
import 'batchpage.dart';

const List<String> manufactureTypes = [
  'Mitre',
  'Add New'
];

class Batch {
  final String batchName;
  final String manufactureType;
  final DateTime dateCreated;

  Batch({
    required this.batchName,
    required this.manufactureType,
    required this.dateCreated,
  });
}

class AddBatchForm extends StatefulWidget {
  const AddBatchForm({
    super.key,
  });

  @override
  State<AddBatchForm> createState() => _AddBatchFormState();
}

class _AddBatchFormState extends State<AddBatchForm> {
  final _formKey = GlobalKey<FormState>();
  final _batchNameController = TextEditingController();
  String manufactureType = manufactureTypes.first;
  Batch batch = Batch(batchName: 'M', manufactureType: '', dateCreated: DateTime.now());  
  @override
  void dispose() {
    _batchNameController.dispose();
    //_manufactureTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //DateFormat dateformat = DateFormat('dd-MM-yyyy');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Text('Create a new Batch', style: TextStyle(fontSize: 20,)),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _batchNameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.view_agenda_outlined),
                    labelText: 'Batch Name',
                    hintText: 'M020'
                    ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name for the batch';
                    }
                    return null;
                  },
                  onChanged: (String? value) {
                    setState(() {
                      //batch.batchName = value!;
                    });
                  },
                  onSaved: (String? value) {
                    Batch(batchName: value!, manufactureType: manufactureType, dateCreated: DateTime.now());
                    debugPrint('Batch Name: $value'); 
                  },
                ),
                const SizedBox(height:10),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.build),
                    labelText: 'Manufacture Type',
                  ),
                  value: manufactureType,
                  items:manufactureTypes.map((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      manufactureType = value!;
                    });
                  },
                  onSaved: (String? value) {
                    debugPrint('Manufacture Type: $value');
                  },
                ),
                const SizedBox(height:10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    backgroundColor: const Color.fromARGB(255, 39, 88, 128),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      //ScaffoldMessenger.of(context).showSnackBar(
                      //  const SnackBar(content: Text('Batch added successfully'))
                      //);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => BatchPage(batchName: _batchNameController.text))
                      );
                    }
                  },
                  child: const Text('Add Batch'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
