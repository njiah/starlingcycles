import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart'; 
import 'database.dart';
import 'batchpage.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.manufactureName, style: const TextStyle(color: Colors.white)),
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
              borderRadius: BorderRadius.circular(25),
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