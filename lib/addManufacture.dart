import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database.dart';
import 'batchpage.dart';


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
  String error = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getProcesses();
  }

  @override
  void dispose() {
    _manufactureNameController.dispose();
    super.dispose();
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
      final manufacture = {
        'manufactureName': _manufactureNameController.text, 
        'procedure': procedureList.join(',') 
      };
      if (procedureList.isEmpty) {
        setState(() {
          error = 'Please add at least one process.';
        });
        
      }
      else{  
        final exist = await dbHelper.insertManufacture('Manufacture', manufacture);
        if (exist == 0) {
          setState(() {
            error = '${manufacture['manufactureName']} already exists';
          });
        }
        else {
          Navigator.pop(context, true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Add Manufacturing Type', style: TextStyle(color: Colors.white)),
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
              if (error.isNotEmpty) 
                Text(error, style: const TextStyle(color: Colors.red)),
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
              ),
              const SizedBox(height: 50),
              Row(
                children: <Widget> [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: processes.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ListTile(
                            title: Text(processes[index]),
                            trailing: Draggable<String>(
                              data: processes[index],
                              feedback: Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  width: processes[index].length + 250,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(10), 
                                    //border: Border.all(color: Theme.of(context).primaryColor),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.drag_handle, color: Colors.white,),
                                      const Spacer(),
                                      Text(processes[index], style: const TextStyle(fontSize: 18,color: Colors.white, decoration: TextDecoration.none)),
                                      ],
                                    )
                                  ),
                              ),
                              childWhenDragging: const Icon(Icons.drag_handle, color: Colors.grey),
                              child: const Icon(Icons.drag_handle),
                            )
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
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.65,
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
  String error = '';

  void _addProcess() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print(processType);
      final process = {
        'processName': _processNameController.text,
        'processType': processType,
      };
      final exist = await dbHelper.insertProcess('Process', process);
      if (exist != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Process added successfully'))
        );
        Navigator.pop(context, true);
      }
      else {
        setState(() {
          error = '${process['processName']} already exists';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: error.isNotEmpty ? Text(error, style: const TextStyle(color: Colors.red)) : const Text('Add New Process'),
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