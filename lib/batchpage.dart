import 'dart:ffi';
import 'dart:async';
import 'home.dart';
import 'addbatch.dart';
import 'package:flutter/material.dart'; 
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

class Frame {
  final String frameNumber;
  final String model;
  final String size;
  final DateTime dateCreated;

  Frame({
    required this.frameNumber,
    required this.model,
    required this.size,
    required this.dateCreated,
  });
}

class BatchPage extends StatefulWidget {
  final String? batchName;
  const BatchPage({Key? key, required this.batchName}) : super(key: key);
  @override
  State<BatchPage> createState() => _BatchPageState();
}

class _BatchPageState extends State<BatchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.batchName!, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView(
          padding: const EdgeInsets.all(50),
          shrinkWrap: false,
          children: [
            BatchTable(),
            const SizedBox(height: 50),
            TimerWidget(),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return const AddFrameForm();
            },
          );
        },
        tooltip: 'Add Batch',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white, size:28),
      ),
    );
  }
}

class BatchTable extends StatefulWidget {
  List frames = [];
  BatchTable({Key? key, this.frames = const []});
  @override
  State<BatchTable> createState() => _BatchTableState();
}
class _BatchTableState extends State<BatchTable> {
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

class AddFrameForm extends StatefulWidget{
  const AddFrameForm({
    super.key,
  });

  @override
  State<AddFrameForm> createState() => _AddFrameFormState();
}

class _AddFrameFormState extends State<AddFrameForm> {
  final _formKey = GlobalKey<FormState>();
  final _frameNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _sizeController = TextEditingController();

  @override
  void dispose() {
    _frameNumberController.dispose();
    _modelController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return AlertDialog.adaptive(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: const Text('Add Frame'),
      content: Container(
        width: 400,
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextField(
                controller: _frameNumberController,
                decoration: const InputDecoration(
                  labelText: 'Frame Number',
                ),
              ),
              TextField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                ),
              ),
              TextField(
                controller: _sizeController,
                decoration: const InputDecoration(
                  labelText: 'Size',
                ),
              ),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Date Created',
                ),
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
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class TimerWidget extends StatefulWidget {
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
              onPressed: stopTimer,
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}