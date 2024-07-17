import 'package:flutter/material.dart';
import 'batchpage.dart';
import 'database.dart'; 

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
  //const AddBatchForm({super.key,});

  @override
  State<AddBatchForm> createState() => _AddBatchFormState();
}

class _AddBatchFormState extends State<AddBatchForm> {
  final DatabaseHelper dbHelper = DatabaseHelper();  
  final _formKey = GlobalKey<FormState>();

  List<String> manufactureTypes = [];
  final _batchNameController = TextEditingController();
  String? manufactureType;
  String _batchNameError = ''; 
  Batch batch = Batch(batchName: 'M', manufactureType: '', dateCreated: DateTime.now());  
  
  @override
  void dispose() {
    //_batchNameController.dispose();
    //_manufactureTypeController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _getManufactureType();
  }

  void _getManufactureType() async {
    final data = await dbHelper.query('Manufacture');
    setState(() {
      manufactureTypes = data.map((item) => item['manufactureName'] as String).toList();
      if (manufactureTypes.isNotEmpty) {
        manufactureType = manufactureTypes[0];
      }
      else {
        manufactureType = 'Add New';
      }
    });
  }

  void _validateBatchName(String value) {
    if (value.isEmpty) {
      setState(() {
        _batchNameError = 'Please enter a batch name';
      });
    }
    else if (!isBatchNamevalid(value)) {
      setState(() {
        _batchNameError = 'Please enter a valid batch name';
      });
    }
    else {
      setState(() {
        _batchNameError = '';
      });
    }
  }

  bool isBatchNamevalid(String name){
    return RegExp(r'^([A-Z]\d{3})$').hasMatch(name);
  }

  void insertBatch() async{
    if(_formKey.currentState!.validate()){
      Map<String, dynamic> row = {
        'batchName': _batchNameController.text,
        'manufacture': manufactureType,
        'date_created': DateTime.now().toString(), 
      };
      print(row);
      await dbHelper.insertItem('Batch', row);
      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Batch added successfully'))
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => BatchPage(batchName: row['batchName'])) 
      );
      _batchNameController.clear();
    }
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
                    hintText: 'M020',
                    //errorText: _batchNameError,
                    ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a batch name';
                    }
                    else if (!isBatchNamevalid(value)) {
                      return 'Please enter a valid batch name';
                    }
                    return null;
                  },
                  onChanged: _validateBatchName,
                  onSaved: (String? value) {
                    Batch(batchName: value!, manufactureType: manufactureType.toString(), dateCreated: DateTime.now());
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
                  items: manufactureTypes.map((String value) {
                    return DropdownMenuItem(
                      value: manufactureType,
                      child: Text(manufactureType.toString()),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      manufactureType = value;
                    });
                  },
                ),
                const SizedBox(height:10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    backgroundColor: const Color.fromARGB(255, 39, 88, 128),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: insertBatch,
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
