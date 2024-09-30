import 'dart:ffi';
import 'dart:async';
import 'package:flutter/services.dart';
import 'home.dart';
import 'addbatch.dart';
import 'package:flutter/material.dart'; 
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart'; 
import 'progresspage.dart';


class BatchPage extends StatefulWidget {
  final String batchName;
  const BatchPage({Key? key, required this.batchName}) : super(key: key);
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
      print(status);
    });
    final data = await dbHelper.getBatchFrame('Frame', widget.batchName);
    print(data);
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
    await dbHelper.deleteFrame('Frame', frameNumber);
  }

  @override
  Widget build(BuildContext context) {
    final String batchName = widget.batchName;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.batchName, style: const TextStyle(color: Colors.white)),
        actions: status != 'Completed' ? [
          Container(
            margin: const EdgeInsets.only(right: 25),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color.fromARGB(255, 152, 201, 111), 
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
          )
        ] : null,
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
              child: Center(
                child: Text(
                  'Manufacture Type: $manufactureType, Date Created: $dateCreated',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
                          //_deleteFrame(e['frameNumber']);
                          //_queryFrames();
                          //frames.remove(e);
                        },),
                    ))
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

/*class BatchTable extends StatefulWidget {
  List frames = [];
  //BatchTable({Key? key, this.frames = const []});
  @override
  State<BatchTable> createState() => _BatchTableState();
}
class _BatchTableState extends State<BatchTable> {
  List<Map<String, dynamic>> _frames = [];
  final dbHelper = DatabaseHelper();
  void initState() {
    super.initState();
    _queryFrames();
  }
  void _queryFrames() async {
    final data = await dbHelper.query('SC_account');
    setState(() { 
      _frames = data; 
      });
  }
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Text(
            'Frame Number',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        DataColumn(
          label: Text(
            'Model',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        DataColumn(
          label: Text(
            'Size',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        DataColumn(
          label: Text(
            'Date Created',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ],
      rows: const <DataRow>[
        DataRow(
          cells: <DataCell>[
            DataCell(Text('M879')),
            DataCell(Text('Murmur')),
            DataCell(Text('L')),
            DataCell(Text('01-01-2022')),
          ],
        ),
        DataRow(
          cells: <DataCell>[
            DataCell(Text('M879')),
            DataCell(Text('Murmur')),
            DataCell(Text('L')),
            DataCell(Text('01-01-2022')),
          ],
        ),
        DataRow(
          cells: <DataCell>[
            DataCell(Text('M879')),
            DataCell(Text('Murmur')),
            DataCell(Text('L')),
            DataCell(Text('01-01-2022')),
          ],
        ),
      ],
    );
  }
}
*/

/*class FrameTable extends StatefulWidget {
  final String batchName;
  List<Map<String, dynamic>> frames = []; 
  FrameTable({Key? key, required this.batchName, required this.frames}) : super(key: key);
  @override
  State<FrameTable> createState() => _FrameTableState();
}
class _FrameTableState extends State<FrameTable>{
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> frames = [];

  @override
  void initState() {
    super.initState();
    _getFrames();
  }

  void _deleteFrame(String frameNumber) async {
    await dbHelper.deleteFrame('Frame', frameNumber);
  }

  void _getFrames() async {
    final data = await dbHelper.getBatchFrame('Frame', widget.batchName);
    setState(() {
      frames = data;
    });
  }

  @override
  Widget build(BuildContext context){
    final items = widget.frames;
    if (items.isEmpty) {

      return const Center(
          child: Text('No frames yet'),
      );
    }
    else {
      return DataTable(
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
        rows: items.map(
          (e) => DataRow(cells: [
            DataCell(Text(e['frameNumber'])),
            DataCell(Text(e['model'])),
            DataCell(Text(e['size'])),
            DataCell(
              Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: (){
                    _deleteFrame(e['frameNumber']);
                    _getFrames();
                  },),
              ))
          ])).toList(),
      );
    }
  }
}*/

class AddFrameForm extends StatefulWidget{
  final String batchName;
  const AddFrameForm({Key? key, required this.batchName}) : super(key: key);

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
      final addedFrame = await dbHelper.insertFrame('Frame', frame);
      if (addedFrame == 0) {
        setState(() {
          frameError = 'Frame already exists!';
        });
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Frame added')),
        );
        Navigator.pop(context, true);
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

/*class TimerWidget extends StatefulWidget {
  //const TimerWidget({Key? key}) : super(key: key);
  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}
class _TimerWidgetState extends State<TimerWidget>{
  int _seconds = 0;
  Timer? _timer;
  bool _isActive = false;

  @override
  void dispose(){
    _timer?.cancel();
    super.dispose();
  }

  void startTimer(){
    if (_isActive) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });

    setState((){
      _isActive = true;
    });
  }
  
  void stopTimer(){
    //if (!_isActive) return;

    _timer?.cancel();
    setState((){
      _seconds = 0;
      _isActive = false;
    });
  }

  void pauseTimer(){
    if (!_isActive) return;

    _timer?.cancel();
    setState((){
      _isActive = false;
    });
  }

  bool selected = false;  
  @override
  Widget build(BuildContext context){
    String formattedTime = DateFormat('HH:mm:ss').format(DateTime(0).add(Duration(seconds: _seconds)));
    return Column(
      children: <Widget>[
        Text(
          formattedTime,
          style: const TextStyle(fontSize: 48),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton.filledTonal(
              isSelected: selected,
              icon: const Icon(Icons.play_arrow),
              selectedIcon: const Icon(Icons.pause),
              onPressed: (){
                if (selected) {
                  pauseTimer();
                } else {
                  startTimer();
                }
                setState(() {
                  selected = !selected;
                });
              },
              //child: const Text('Start'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: (){
                stopTimer();
                setState(() {
                  selected = false;
                });
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}*/