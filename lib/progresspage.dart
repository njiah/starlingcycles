import 'dart:convert';
import 'dart:io';
import 'database.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart'; 
import 'package:share_plus/share_plus.dart'; 

class CheckboxProcess {
  final String frameNumber;
  bool isChecked;

  CheckboxProcess({
    required this.frameNumber,
    this.isChecked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'frameNumber': frameNumber,
      'isChecked': isChecked,
    };
  }
}

class ProgressPage extends StatefulWidget {
  final String batchname;
  const ProgressPage({Key? key, required this.batchname}) : super(key: key); 
  //final List procedure;
  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> frames;
  List procedure = [];
  List processes = [];
  List processTypes = [];
  String csv = '';
  
  @override
  void initState(){
    super.initState();  
    frames = dbHelper.getBatchFrame('Frame', widget.batchname);
    getProcesses();
    //addProcess();
  }
  void getProcesses() async {
    final batch = await dbHelper.getBatch('Batch', widget.batchname);
    final process = await dbHelper.getManufacture('Manufacture', batch[0]['manufacture']);
    procedure = process[0]['procedure'].split(',');
    //final data = await dbHelper.getProcess('Process', procedure[0]);
    for (int i = 0; i < procedure.length; i++) {
      String process = procedure[i];
      final data = await dbHelper.getProcess('Process', process);
      processes.add(data[0]['processName']);
      processTypes.add(data[0]['processType']);
      await dbHelper.addProcesses(processes[i], processTypes[i]); 
    }
    setState(() {
      processes = processes;
      processTypes = processTypes;
    });
  }

  void addProcess() async {
    for (int i = 0; i < processes.length; i++) {
      await dbHelper.addProcesses(processes[i], processTypes[i]); 
    }
  }

  Future<void> generateCSV() async{
    
    final frames = await dbHelper.getBatchFrame('Frame', widget.batchname);
    List<List<dynamic>> rows = [];
    if (frames.isNotEmpty){
      rows.add(frames.first.keys.toList());
    }
    for (var row in frames){
      rows.add(row.values.toList());
    }
    String csv = const ListToCsvConverter().convert(rows);
    //print(csv);
    
    final String directory = (await getApplicationDocumentsDirectory()).path;
    final String path = '$directory/${widget.batchname}.csv';
    final File file = File(path);
    await file.writeAsString(csv);
    print(csv);
    print('CSV saved at $path');

  }

  Future<void> saveCSV(String csv) async {
    try{
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${widget.batchname}.csv';
      final file = File(path);  
      await file.writeAsString(csv);
      print('CSV saved at $path');
    }
    catch(e){
      print('Error: $e');
    }
  }

  Future<void> requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      print('Permission Granted');
    }
    else {
      print('Permission Denied');
    }
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.batchname, style: const TextStyle(color: Colors.white)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: () {
                generateCSV();
                showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog.adaptive(
                      scrollable: true,
                      title: const Text('Export CSV'),
                      content: const Text("Do you want to export the CSV file?"),
                      actions: [
                        TextButton(
                          onPressed: () async{
                            final directory = await getApplicationDocumentsDirectory();
                            final path = '${directory.path}/${widget.batchname}.csv';
                            final data = File(path).openRead();
                            print(path);
                            data.transform(utf8.decoder).transform(const LineSplitter()).forEach((element) {
                              print(element);
                            });
                            //print(data);
                            Share.shareXFiles([XFile(path)], text: 'CSV file for ${widget.batchname}'); 
                            dbHelper.updateStatus(widget.batchname, 'Completed');
                            Navigator.of(context).pop();
                          }, 
                          child: const Text('Share'),
                        ),
                        TextButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          }, 
                          child: const Text('Cancel'),
                        ),
                      ],
                    );
                  },
                );
              }, 
              child: const Text('Export CSV', style: TextStyle(color: Colors.white)),
              )
            ),
        ],
        ),
        body: ProgressTab(batchName: widget.batchname, processes: processes, processTypes: processTypes),
        );
  }
}

class ProgressTab extends StatefulWidget {
  final String batchName;
  final List processes;
  final List processTypes;
  const ProgressTab({super.key, required this.batchName, required this.processes, required this.processTypes});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {

  final dbHelper = DatabaseHelper();
  List frames = [];
  List processes = [];  
  String time = '00:00:00';
  Map<String, bool> checkAll = {};
  Map<String, Map<String, bool>> checked = {};
  Map<String, Map<String, bool>> expanded = {}; 

  @override
  void initState(){
    super.initState();
    _getFrames();
  }

  void _getFrames() async {
    final data = await dbHelper.getBatchFrame('Frame', widget.batchName);
    final processTypes = await dbHelper.query('Process'); 
    setState(() {
      frames = data;
      for (int i = 0; i < processTypes.length; i++) {
        if (processTypes[i]['processType'] == 'tick') {
          String processName = processTypes[i]['processName'];
          processName = processName.replaceAll(' ', '');
          checkAll[processName] = false;
          checked[processTypes[i]['processName']] = {for (var frame in frames) frame['frameNumber']: frame[processName]== 1};
        }
        else {
          String processName = processTypes[i]['processName'];
          processName = processName.replaceAll(' ', '');
          expanded[processName] = {for (var frame in frames) frame['frameNumber']: frame[processName] == false};
        }
      }
    });
  }

  void updateProcess(String frameNumber, String process, bool value) async {
    await dbHelper.updateProcessTick(frameNumber, process, value);
  }

  @override
  Widget build(BuildContext context) {
    processes = [for (int i = 0; i < widget.processes.length; i++) widget.processes[i].replaceAll(' ', '')];  
    return DefaultTabController(
      length: widget.processes.length,
      child: Column(
        children: [
          Material(
            child: Container(
              color: Theme.of(context).colorScheme.primary,
              child: Container(
                child: TabBar(
                  isScrollable: true,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(width: 2.0, color: Colors.white),
                    insets: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    for (int i = 0; i < widget.processes.length; i++)
                      Tab(
                        child: Text(
                          widget.processes[i].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        )
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                for(int i = 0; i < widget.processes.length; i++)
                  Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(top:20, left: 100, right: 100),
                          separatorBuilder: (BuildContext context, int index) => const Divider(),  
                          itemCount: frames.length,
                          itemBuilder: (context, index){
                            String time = frames[index][processes[i]].toString() == 'null' ? '00:00:00' : frames[index][processes[i]].toString();
                            if (widget.processTypes[i] == 'timer'){
                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ExpansionTile(
                                leading: IconButton(
                                  icon: const Icon(Icons.comment_outlined),
                                  onPressed: (){
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context)
                                        {
                                          return CommentDialog(frameNumber: frames[index]['frameNumber']);
                                        }
                                      );
                                  },
                                ),
                                title: Text("${frames[index]['frameNumber']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                //leading: const Icon(Icons.timer),
                                subtitle: expanded[processes[i]]![frames[index]['frameNumber']] == true
                                ? TimerClock(frameNumber: frames[index]['frameNumber'], processName: processes[i]) 
                                : Text(time),
                                onExpansionChanged: (bool? expand) async {
                                  setState(() {
                                    expanded[processes[i]]![frames[index]['frameNumber']] = expand!;
                                  });
                                  frames = await dbHelper.getBatchFrame('Frame', widget.batchName);
                                },
                                /*children: [
                                  TimerClock(frameNumber: frames[index]['frameNumber'], processName: processes[i]),
                                ],*/
                                ),
                            );
                            }
                            else {
                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                ),
                                child: CheckboxListTile(
                                  secondary: IconButton(
                                    icon: const Icon(Icons.comment_outlined),
                                    onPressed: (){
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context)
                                        {
                                          return CommentDialog(frameNumber: frames[index]['frameNumber']);
                                        }
                                      );
                                    },
                                  ),
                                  title: Text("${frames[index]['frameNumber']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  //subtitle: Text(frames[index][processes[i]].toString()),
                                  value: checked[widget.processes[i]]![frames[index]['frameNumber']],   
                                  onChanged: (bool? value) {
                                      setState(() {
                                        checked[widget.processes[i]]![frames[index]['frameNumber']] = value!;
                                        updateProcess(frames[index]['frameNumber'], processes[i], value);
                                        if (checked[widget.processes[i]]!.values.every((element) => element == true)) {
                                          checkAll[processes[i]] = true;
                                        }
                                      }
                                      );
                                  },
                                ),
                              );
                              }
                            }
                        ),
                      ),
                      if (widget.processTypes[i] == 'tick')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10), 
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 229, 227, 223),
                          ),
                          onPressed: (){
                            setState(() {
                              print(checkAll);
                              checkAll[processes[i]] = !checkAll[processes[i]]!;
                              for (int j = 0; j < frames.length; j++) {
                                checked[widget.processes[i]]![frames[j]['frameNumber']] = checkAll[processes[i]]!;
                                updateProcess(frames[j]['frameNumber'], processes[i], checkAll[processes[i]]!);
                              }
                            });
                          }, 
                          child: Text(checkAll[processes[i]]==true ? 'Deselect All' : 'Select All'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimerClock extends StatefulWidget {
  final String frameNumber;
  final String processName;
  TimerClock({Key? key, required this.frameNumber, required this.processName}) : super(key: key);

  @override
  State<TimerClock> createState() => _TimerClockState();
}

class _TimerClockState extends State<TimerClock> {
  //late AnimationController controller;
  int _seconds = 0;
  Timer? _timer;
  bool _isActive = false;
  bool selected = false;  
  final dbHelper = DatabaseHelper();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
    setState(() {
      _isActive = true;
    });
  }
  void stopTimer() {
    _timer?.cancel();
    setState((){
      _seconds = 0;
      _isActive = false;
    });
  }
  void pauseTimer() {
    if (!_isActive) return;
    _timer?.cancel();
    setState(() {
      _isActive = false;
    });
  }

  void showdialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Timer'),
          content: const Text('Process Time has been updated'),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              }, 
              child: const Text('OK'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('HH:mm:ss').format(DateTime.utc(0, 0, 0, 0, 0, _seconds));
    return Column(
          children: [
            Text(formattedTime, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  isSelected: selected,
                  onPressed: (){
                    if(selected){
                      pauseTimer();
                    }
                    else {
                      startTimer();
                    }
                    setState(() {
                      selected = !selected;
                    });
                  }, 
                  icon: const Icon(Icons.play_arrow),
                  selectedIcon: const Icon(Icons.pause),
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
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Done', style: TextStyle(color: Colors.white),),
                  onPressed: (){
                    pauseTimer();
                    setState(() {
                      selected = false;
                    });
                    dbHelper.updateProcessTimer(widget.frameNumber, widget.processName, formattedTime);
                    //showdialog(context); 
                  },
                )
              ],
            ),
          ],
        
      );
  }
}

class ExportCSV extends StatefulWidget {
  final Future<dynamic> data;
  const ExportCSV({super.key, required this.data});

  @override
  State<ExportCSV> createState() => _ExportCSVState();
}
class _ExportCSVState extends State<ExportCSV> {
  final dbHelper = DatabaseHelper();
  List<List<dynamic>> table = [];
  @override
  void initState(){
    super.initState();
    getCSV();
  }
  void exportCSV() async {
    final csv = await widget.data;
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    final directory = await getExternalStorageDirectory();
    final path = directory!.path;
    final file = File('$path/Export.csv');
    file.writeAsString(csv);
  }
  void getCSV() async {
    table = const CsvToListConverter().convert(await widget.data);
    setState(() {
      table = table;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text('Export CSV'),
      content: Container(
        child: DataTable(
          columns: [
            for (int i = 0; i < table.length; i++)
              DataColumn(
                label: Text(table[0][i].toString()),
              ),
            ],
          rows: [
            DataRow(
              cells: [
                for (int i = 0; i < table[1].length; i++)
                  DataCell(
                    Text(table[1][i].toString()),
                  ),
              ],
            ),
            ],
          ),
      ),
      actions: [
        TextButton( 
          onPressed: () {

          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: (){
            Navigator.of(context).pop();
          }, 
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class CommentDialog extends StatefulWidget {
  final String frameNumber;
  const CommentDialog({super.key, required this.frameNumber});

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final commentController = TextEditingController();  
  final editController = TextEditingController();
  List<Map<String, dynamic>> frame = [];
  String comments = '';

  @override
  void initState(){
    super.initState();
    getFrame();
  }

  void getFrame() async{
    frame = await dbHelper.getFrame(widget.frameNumber);
    if (frame[0]['comment'] != null) {
      setState(() {
        comments = frame[0]['comment'];
        commentController.text = comments;  
      });
    }
  }

  void save() async{
    await dbHelper.updateComment(widget.frameNumber, comments.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text('Add Comment for ${widget.frameNumber}'),
      content: SizedBox(
        width: 400,
        child: Column(
          children: [
            comments != '' ?
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(overflow: TextOverflow.clip, comments)
                  ),
                  //const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: (){
                      setState(() {
                        comments = '';
                      });
                    },
                  ),
                ],
              ),
            ): 
            TextField(
              //autofillHints: const [AutofillHints.],
              keyboardType: TextInputType.multiline,
              controller: comments != '' ? editController : commentController,  
              maxLines: 5,
              decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your comments here',  
              ),
            ),
          ]
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await dbHelper.updateComment(widget.frameNumber, commentController.text);
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          }, 
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: (){
            Navigator.of(context).pop();
          }, 
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}