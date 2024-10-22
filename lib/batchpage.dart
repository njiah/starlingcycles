import 'package:flutter/services.dart';
import 'package:flutter/material.dart'; 
import 'database.dart'; 
import 'progresspage.dart';


class BatchPage extends StatefulWidget {
  final String batchName;
  const BatchPage({super.key, required this.batchName});
  @override
  State<BatchPage> createState() => _BatchPageState();
}

class _BatchPageState extends State<BatchPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> frames = [];
  String manufactureType = '';
  List procedure = [];
  bool empty = true;
  String status = ''; 
  String dateCreated = '';
  String dateCompleted = '';

  @override
  void initState() {
    super.initState();
    _queryFrames();
    getManufactureType();
    //getProcedure();
  }
  
  void _queryFrames() async {
    final batch = await dbHelper.getBatch('Batch', widget.batchName);
    setState(() {
      status = batch[0]['Status'];
      dateCreated = batch[0]['dateCreated'];
      dateCompleted = batch[0]['dateCompleted']?? ''; 
    });
    final data = await dbHelper.getBatchFrame('Frame', widget.batchName);
    if (data.isNotEmpty) {
      setState(() {
        frames = data;
        empty = false;
      });
    } 
    else{
      setState(() {
        empty = true;
      });
    }
  }

  void getManufactureType() async {
    final data = await dbHelper.getBatch('Batch', widget.batchName);
    setState(() {
      manufactureType = data[0]['manufacture'];
    });
  }

  void getProcedure() async {
    final data = await dbHelper.getManufacture('Manufacture', manufactureType);
    setState(() {
      String procedureString = data [0]['procedure'];
      procedure = procedureString.split(',');
    });
  }

  void _deleteFrame(String frameNumber) async {
    await dbHelper.deleteFrame('Frame', frameNumber, widget.batchName);
  }
  void _deleteBatch(String batchName) async {
    await dbHelper.deleteBatch('Batch', batchName);
  }

  @override
  Widget build(BuildContext context) {
    final String batchName = widget.batchName;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context, 'trigger');
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.batchName, style: const TextStyle(color: Colors.white)),
        actions:[
          status != 'Completed' ? 
          Container(
            margin: const EdgeInsets.only(right: 25),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 152, 201, 111), 
              //side: const BorderSide(color: Colors.white),
              ),
              onPressed: empty ? null : 
              (){
                if (status == 'Not Started') {
                  dbHelper.updateStatus(widget.batchName, 'In Progress');
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProgressPage(batchname:batchName)),
                );
              },
              child: status == 'In Progress' ? const Text('Continue') : const Text('Start'),
            ),
          ):
          Container(
            margin: const EdgeInsets.only(right: 25),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red, 
              //side: const BorderSide(color: Colors.white),
              ),
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: const Text('Delete Batch'),
                      content: const Text('Are you sure you want to delete this batch?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteBatch(widget.batchName);
                            Navigator.pop(context);
                            Navigator.pop(context, 'trigger');
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Delete'),
            ),
          ),
        ],
      ),
      body: ListView(
          padding: const EdgeInsets.all(50),
          shrinkWrap: false,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                  'Manufacture Type: $manufactureType',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Date Created: $dateCreated',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      status == 'Completed' ? Text(
                        'Date Completed: $dateCompleted',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ) : 
                      const Spacer(),
                      /*Text(
                        'Status: $status',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),*/
                    ],
                  ),
                ]
              ),
            ),
            Container(
              constraints: const BoxConstraints(minHeight: 200),
              margin: const EdgeInsets.only(top: 20), 
              padding: const EdgeInsets.only(top: 30, bottom: 40, left: 20, right: 20), 
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: empty
              ? const Center(
                child: Text('No frames yet'),
              )
              : DataTable(
              columns: const [
                DataColumn(label: Text(
                  'Frame Number',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),),
                DataColumn(label: Text(
                  'Model',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  )),
                DataColumn(label: Text(
                  'Size',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                DataColumn(label: Text(''))
              ], 
              rows: frames.map(
                (e) => DataRow(cells: [
                  DataCell(Text(e['frameNumber'])),
                  DataCell(Text(e['model'])),
                  DataCell(Text(e['size'])),
                  status != 'Completed' ?
                  DataCell(
                    Container(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: (){
                          showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return AlertDialog(
                                title: const Text('Delete Frame'),
                                content: const Text('Are you sure you want to delete this frame?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: (){
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: (){
                                      _deleteFrame(e['frameNumber']);
                                      _queryFrames();
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                            
                          );
                        },),
                    )):DataCell(Container()),
                ])).toList(),
              )
            ),
            const SizedBox(height: 50),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context, 
            builder: (BuildContext context) {
              return AddFrameForm(batchName: widget.batchName);
            },
          );
          if (result == true) {
            _queryFrames();
          }
        },
        tooltip: 'Add a new Frame',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white, size:28),
      ),
    );
  }
}


class AddFrameForm extends StatefulWidget{
  final String batchName;
  const AddFrameForm({super.key, required this.batchName});

  @override
  State<AddFrameForm> createState() => _AddFrameFormState();
}

class _AddFrameFormState extends State<AddFrameForm> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final _frameNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _sizeController = TextEditingController();
  String error = '';
  String frameError = '';

  @override
  void dispose() {
    _frameNumberController.dispose();
    _modelController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void _validateFrame(String value){
    if (value.isEmpty) {
      setState(() {
        error = 'Please enter a frame number';
      });
    }
    else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      setState(() {
        error = 'Frame number must be alphanumeric';
      });
    }
    else {
      setState(() {
        error = '';
      });
    }
  }
  
  void _addFrame() async {
    if (_formKey.currentState!.validate()) {
      final frame = {
        'frameNumber': _frameNumberController.text,
        'model': _modelController.text,
        'size': _sizeController.text,
        'batchNumber': widget.batchName,  
      };
      final exist = await dbHelper.getFrame(_frameNumberController.text);
      if (exist.isNotEmpty) {
        setState(() {
          frameError = 'Frame already exists!';
        });
      }
      else {
        frameError = '';
        await dbHelper.insertFrame('Frame', frame);
      }
    }
  }

  @override
  Widget build(BuildContext context){
    return AlertDialog.adaptive(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: frameError.isEmpty 
      ? const Text('Add Frame') 
      : Text(frameError, style: const TextStyle(color: Colors.red)),
      content: Container(
        width: 400,
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
                controller: _frameNumberController,
                decoration: const InputDecoration(
                  labelText: 'Frame Number',
                  hintText: 'e.g. M879',
                ),
                validator: (value){
                  if (value == null || value.isEmpty) {
                    return 'Please enter a frame number';
                  }
                  else if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
                    return 'Frame number must be alphanumeric';
                  }
                  return null;
                },
                onChanged: _validateFrame,
              ),
              TextFormField(
                controller: _modelController,
                inputFormatters: <TextInputFormatter> [UpperCaseTextFormatter()], 
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: "e.g. Murmur",
                ),
                validator: (value){
                  if (value == null || value.isEmpty) {
                    return 'Please enter a model';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sizeController,
                inputFormatters: <TextInputFormatter>[SizeTextFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Size',
                  hintText: 'e.g. L',
                ),
                validator: (value){
                  if (value == null || value.isEmpty) {
                    return 'Please enter a size';
                  }
                  else if (!RegExp(r'[A-Z]').hasMatch(value)){
                    return 'Please enter a valid size';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _addFrame();
            if (frameError!='') {
              Navigator.of(context).pop(true);
            }
          },
          child: const Text('Add'),
        ),
      ],
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

class SizeTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
