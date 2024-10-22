import 'package:flutter/material.dart';
import 'package:starlingcycles/database.dart';
import 'addManufacture.dart';
import 'manufacturepage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(50),
      shrinkWrap: true,
      children: const [
        ManufactureTypesBox(),
      ],
    );
  }
}

class ManufactureTypesBox extends StatefulWidget {
  const ManufactureTypesBox({super.key});
  @override
  State<ManufactureTypesBox> createState() => _ManufactureTypesBoxState();
}

class _ManufactureTypesBoxState extends State<ManufactureTypesBox>{
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> manufactureTypes = [];
  List<Map<String, dynamic>> processNames = [];
  List<Map<String, dynamic>> process = [];

  @override
  void initState() {
    super.initState();
    _getManufactureType();
    _getProcesses();
  }

  void _getManufactureType() async {
    final data = await dbHelper.query('Manufacture');
    setState(() {
      manufactureTypes = data;
    });
  }

  void _getProcesses() async {
    final data = await dbHelper.query('Process');
    setState(() {
      process = data;
    });
  }
  void _deleteProcess(String processID, String processName) async {
    await dbHelper.deleteProcess(processID, processName);
    _getProcesses();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Stack(
          children: [
            Container(
            height: 250,
            padding: const EdgeInsets.only(left: 10, right: 10, top: 50, bottom: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],  
            ),
          child: FutureBuilder(
              future: dbHelper.query('Manufacture'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                else {
                  final data = snapshot.data as List<Map<String, dynamic>>;
                  if (data.isEmpty) {
                    return const Center(child: Text('No Data'));
                  }
                  else {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(5),
                      itemCount: manufactureTypes.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            final result = Navigator.of(context).push(MaterialPageRoute(builder: (context) => ManufacturePage(manufactureName: manufactureTypes[index]['manufactureName'])));
                            result.then((value) {
                              if (value == true) {
                                _getManufactureType();
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left:5, right:5),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 238, 236, 227),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            width: 220,
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.settings, size: 50, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(height: 70),
                                Text(manufactureTypes[index]['manufactureName'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      }
                    );
                  }
                }
              }
            ),
          ),
          Positioned(
            left: 10,
            top: 5,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: const Text('Manufacture Types', style: TextStyle(fontSize: 20, color: Colors.white))),
          ),
          Positioned(
            right: 10,
            top: 5,
            child: IconButton(
              icon: const Icon(Icons.add),
              color: Colors.white,
              onPressed: () {
                final result = Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddManufactureType()));
                result.then((value) {
                  if (value == true) {
                    _getManufactureType();
                  }
                }); 
              },
            ),
          ),
          ],
        ),
        const SizedBox(height: 20),
        Stack(
          children: [
            Container(
            height: 500,
            padding: const EdgeInsets.only(left: 10, right: 10, top: 50, bottom: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],  
            ),
          child: FutureBuilder(
              future: dbHelper.query('Process'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                else {
                  final data = snapshot.data as List<Map<String, dynamic>>;
                  if (data.isEmpty) {
                    return const Center(child: Text('No Data'));
                  }
                  else {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.all(5),
                      itemCount: process.length,
                      itemBuilder: (context, index) {
                        return Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 238, 236, 227),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: ListTile(
                              leading:Icon(Icons.list, size: 30, color: Theme.of(context).colorScheme.primary),
                              title: Text(process[index]['processName'].toString().toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context, 
                                        builder: (BuildContext context){
                                          return AlertDialog(
                                            title: Text('Delete ${process[index]['processName']}'),
                                            content: Text('${process[index]['processName']} will be deleted from in-progress batches.\nAre you sure you want to delete it?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  _deleteProcess(process[index]['process_id'].toString(), process[index]['processName']);
                                                  _getProcesses();
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
                                      );
                                      //}
                                    },
                                  ),
                                ],),
                            ),
                        );
                      }
                    );
                  }
                }
              }
            ),
          ),
          Positioned(
            left: 10,
            top: 5,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: const Text('Processes', style: TextStyle(fontSize: 20, color: Colors.white))),
          ),
          ],
        ),
      ]
    );
  }
}

