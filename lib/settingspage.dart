import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starlingcycles/database.dart'; 
import 'batchpage.dart';

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

class _ManufactureTypesBoxState extends State<ManufactureTypesBox> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> manufactureTypes = [];
  List<Map<String, dynamic>> processNames = [];

  @override
  void initState() {
    super.initState();
    _getManufactureType();
  }

  void _getManufactureType() async {
    final data = await dbHelper.query('Manufacture');
    setState(() {
      manufactureTypes = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Stack(
          children: [
            Container(
            height: 400,
            padding: const EdgeInsets.only(left: 10, right: 10, top: 50, bottom: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
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
                        return Card(
                          child: Container(
                            width: 250,
                            height: 250,
                            child: Column(
                              children: [
                                const SizedBox(height: 50),
                                Center(
                                  child: Text(manufactureTypes[index]['manufactureName'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                ),
                                Center(
                                  child: Text(manufactureTypes[index]['procedure'], style: const TextStyle(fontSize: 15)),
                                ),
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
      ]
    );
  }
}

class AddManufactureType extends StatefulWidget {
  const AddManufactureType({super.key});
  @override
  State<AddManufactureType> createState() => _AddManufactureTypeState();
}

class _AddManufactureTypeState extends State<AddManufactureType> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController _manufactureNameController = TextEditingController();
  List procedure = [];
  List<String> processes = [];
  List<String> procedureList = [];  
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getProcesses();
  }

  void _getProcesses() async {
    final data = await dbHelper.query('Process');
    setState(() {
      processes = data.map((e) => e['processName'].toString()).toList();
    });
  }

  void _addManufactureType() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      for (var procedureName in procedure){
        final process = await dbHelper.getProcessID('Process', procedureName);
        procedureList.add(process[0]['process_id'].toString());
      }
      print(procedureList);
      final manufacture = {
        'manufactureName': _manufactureNameController.text, 
        'procedure': procedureList.join(',') 
      };
      final exist = await dbHelper.insertManufacture('Manufacture', manufacture);
      if (exist != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manufacture Type added successfully'))
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manufacture Type already exists'))
        );
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Manufacturing Type'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),  
            onPressed: () => _addManufactureType(),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
            //onPressed: _addManufactureType,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _manufactureNameController,
                inputFormatters: <TextInputFormatter> [UpperCaseTextFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Manufacture Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a manufacture name';
                  }
                  return null;
                },
                //onChanged: _validateManufactureName,
              ),
              const SizedBox(height: 50),
              Row(
                children: <Widget> [
                  Container(
                    width: 300,
                    height: 400,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: processes.length,
                      itemBuilder: (context, index) {
                        return Draggable(
                          data: processes[index],
                          feedback: Container(
                            decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.green,
                            ),
                            width: 100,
                            height: 50,
                            child: Center(child: Text(processes[index], style: const TextStyle(fontSize: 15, color: Colors.white))),
                            ),
                          childWhenDragging: Container(
                            decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                            ),
                            //width: 100,
                            height: 50,
                            child: Center(child: Text(processes[index]))
                            ),
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                            ),
                            height: 50,
                            child: Center(child: Text(processes[index]))
                            ),
                          );
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DragTarget(
                      onAcceptWithDetails: (process){
                        setState(() {
                          if (!procedure.contains(process.data))
                            {
                              procedure.add(process.data);
                            }
                        });
                      },
                      builder: (context, acceptedData, rejectedData){
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                            color: Colors.grey[200],
                          ),
                          width: 300,
                          height: 400,
                          child: procedure.isEmpty ? 
                          const Center(child: Text('Drag and drop processes here')) : 
                          ListView.builder(
                            itemCount: procedure.length,
                            itemBuilder: (context, index){
                              return ListTile(
                                title: Text(procedure[index].toString()),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      procedure.removeAt(index);
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog(
            context: context, 
            builder: (BuildContext context){
              return AddProcessForm();
            });
          if (result != null) {
            _getProcesses();
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddProcessForm extends StatefulWidget {
  const AddProcessForm({super.key});
  @override
  State<AddProcessForm> createState() => _AddProcessFormState();
}

class _AddProcessFormState extends State<AddProcessForm> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController _processNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> processTypes = ['tick', 'timer'];  
  String processType = 'timer';

  void _addProcess() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final process = {
        'processName': _processNameController.text,
      };
      final exist = await dbHelper.insertProcess('Process', process);
      if (exist != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Process added successfully'))
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Process already exists'))
        );
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text('Add New Process'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: Container(
        width: 400,
        height: 180,
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _processNameController,
                decoration: const InputDecoration(
                  labelText: 'Process Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a process name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                value: processType,
                items: processTypes.map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    processType = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Process Type',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _addProcess(),
          child: const Text('Save'),
        ),
      ],
    );
  }
}