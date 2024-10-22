import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'batchpage.dart';
import 'database.dart'; 
import 'package:flutter/services.dart';
import 'addManufacture.dart';


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
  const AddBatchForm({super.key});

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
  // ignore: unused_field
  String _batchNameError = ''; 
  String batchError = '';
  
  @override
  void dispose() {
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
      manufactureTypes = data.map((e) => e['manufactureName'].toString()).toList();
      if (manufactureTypes.isNotEmpty) {
        manufactureType = manufactureTypes[0];
      }
      else {
        manufactureTypes = ['Add New'];
        manufactureType = null;
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

  void insertBatch() async {
    if(_formKey.currentState!.validate()){
      String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      Map<String, dynamic> row = {
        'batchName': _batchNameController.text,
        'manufacture': manufactureType,
        'dateCreated': formattedDate, 
      };
      final setup = {
        {
        'frameNumber': 'SETUP',
        'model': ' ',
        'size' : ' ',
        'batchNumber': row['batchName'],
        },
        {
        'frameNumber': 'ALL FRAMES',
        'model': ' ',
        'size' : ' ',
        'batchNumber': row['batchName'],
        },
      };
      final insert = await dbHelper.insertBatch('Batch', row);
      
      if (insert == 0) {
        setState(() {
          batchError = 'Batch already exists';
        });
      }
      else {
        for (var i in setup) {
          dbHelper.insertFrame('Frame', i);
        }
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => BatchPage(batchName: row['batchName']))
        );
        setState(() {
          batchError = '';
        });
      }
      _batchNameController.clear();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          batchError == ''
          ?const Text('Create a new Batch', style: TextStyle(fontSize: 20,))
          : Text(batchError, style: const TextStyle(fontSize: 20, color: Colors.red)),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _batchNameController,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
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
                  validator: (value){
                    if (value == null) {
                      return 'Please add a manufacture type';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.build),
                    labelText: 'Manufacture Type',
                  ),
                  value: manufactureType,
                  items: manufactureTypes.map((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      manufactureType = value;
                    });
                    if (value == 'Add New') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const AddManufactureType())
                        ).then((_){
                          _getManufactureType();
                        });
                    }
                  },
                ),
                const SizedBox(height:10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    backgroundColor: const Color.fromARGB(255, 39, 88, 128),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (){
                    insertBatch();
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
  String capitalize(String value) {
    if(value.trim().isEmpty) {
      return '';
    }
    return value[0].toUpperCase() + value.substring(1).toLowerCase(); 
  }
}

