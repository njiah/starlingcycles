import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:starlingcycles/home.dart';
import 'package:starlingcycles/main.dart'; 
import 'database.dart';
import 'batchpage.dart';
import 'settingspage.dart';

// ignore: must_be_immutable
class ManufacturePage extends StatefulWidget {
  String manufactureName;
  ManufacturePage({super.key, required this.manufactureName});
  @override
  State<ManufacturePage> createState() => _ManufacturePageState();
}

class _ManufacturePageState extends State<ManufacturePage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<String> procedureList = [];
  List<String> procedureString = [];
  List<Map<String, dynamic>> batchNames = [];
  String sort = 'dateCreated';  

  @override
  void initState() {
    super.initState();
    _getManufactureType();
  }

  void _getManufactureType() async {
    final data = await dbHelper.getManufacture('Manufacture', widget.manufactureName);
    procedureList = data.map((e) => e['procedure'].toString()).toList();
    procedureList = procedureList[0].split(',');
    for (var item in procedureList) {
      final process = await dbHelper.getProcess('Process', item);
      setState(() {
        procedureString.add(process[0]['processName'].toString());
      });
    }

    final batches = await dbHelper.query('Batch');
    for (var item in batches) {
      if (item['manufacture'] == widget.manufactureName) {
        batchNames.add(item);
      }
    }
    batchNames.sort((a, b) => a['dateCreated'].compareTo(b['dateCreated']));
  }

  bool batchCheck() {
    for (var batch in batchNames) 
      {if (batch['Status'] != 'Completed') 
        {return true;}
      }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.manufactureName, style: const TextStyle(color: Colors.white)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).secondaryHeaderColor),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
                
              ),
              onPressed: () async {
                batchCheck() ? showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Warning!', style: TextStyle(color: Colors.red)),
                      content: Text('Complete all batches before deleting ${widget.manufactureName}.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        
                      ],
                    );
                  },
                ) : showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete ${widget.manufactureName}'),
                      content: Text('Are you sure you want to delete ${widget.manufactureName}?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            dbHelper.deleteManufacture(widget.manufactureName);
                            Navigator.pop(context, true);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)), 
                        ),      
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                    );
                  },
                ).then((value) {
                  if (value == true){
                    Navigator.pop(context, true);
                  }
                });
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
          )
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(40),
        children: [
          const Positioned(
            top: 20,
            left: 10,
            child: Text(' Procedures:', style: TextStyle(fontSize: 20))),
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(124, 217, 208, 194),
              borderRadius: BorderRadius.circular(7),
            ),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 40, top: 10),
            child: Wrap(
              children: procedureString.map((item) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(item, style: const TextStyle(color: Colors.white)),
                );
              },).toList(),
            ),
          ),
          Row(
            children: [
              const Text('  Batches:', style: TextStyle(fontSize: 20)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Sort by', style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor)),
                  DropdownButton<String>(
                    value: sort,
                    dropdownColor: Colors.grey[200],
                    icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                    underline: Container(
                      height: 1,
                      color: Theme.of(context).primaryColor,
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'dateCreated',
                        child: Text('Date Created'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'dateCompleted',
                        child: Text('Date Completed'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Status',
                        child: Text('Status'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'batchName',
                        child: Text('Batch Name'),
                      ),
                    ],
                  onChanged: (String? value) {
                    setState(() {
                      sort = value!;
                      batchNames.sort((a, b) => a[sort].compareTo(b[sort]));
                    });
                  },
                  ),
                ],
              )
            ],
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            //margin: const EdgeInsets.only(top: 20),
            child: ListView.builder(
              itemCount: batchNames.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                  child: ListTile(
                    title: Text(batchNames[index]['batchName'].toString()),
                    subtitle: Text(batchNames[index]['Status'].toString(), style: TextStyle(color: batchNames[index]['Status'] == 'Completed' ? Colors.green : batchNames[index]['Status'] == 'Not Started'? Colors.red : Colors.grey )), 
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BatchPage(batchName: batchNames[index]['batchName'].toString())));
                    },
                  ),
                );
              },
              shrinkWrap: true,
            ),
          ),
        ]
      ),
    );
  }
}