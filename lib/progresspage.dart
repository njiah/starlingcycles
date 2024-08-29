import 'batchpage.dart';
import 'database.dart';
import 'package:flutter/material.dart';

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
  
  @override
  void initState(){
    super.initState();  
    frames = dbHelper.getBatchFrame('Frame', widget.batchname);
    getProcesses();
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
    }
    setState(() {
      processes = processes;
    });
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.batchname, style: TextStyle(color: Colors.white)),
        actions: [],
        ),
        body: ProgressTab(batchName: widget.batchname, processes: processes,),
        /*ListView(
          padding: const EdgeInsets.all(50),
          shrinkWrap: false,
          children: [
            const SizedBox(height: 50),
            //Text('Manufacture Type: ${widget.manufactureType}'),
            const SizedBox(height: 50),
            Text('Procedure: ${procedure}'),
            const SizedBox(height: 50),
            Text('Processes: ${processes}'),
            const SizedBox(height: 50),
            ProgressTab(batchName: widget.batchname, processes: processes,),
          ],
        ),*/
        );
  }
}

class ProgressTab extends StatefulWidget {
  final String batchName;
  final List processes;
  const ProgressTab({Key? key, required this.batchName, required this.processes}) : super(key: key);

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {

  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> frames = [];

  @override
  void initState(){
    super.initState();
    _getFrames();
  }

  void _getFrames() async {
    final data = await dbHelper.getBatchFrame('Frame', widget.batchName);
    setState(() {
      frames = data;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          widget.processes[i],
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
                for (int i = 0; i < widget.processes.length; i++)
                  ListView.separated(
                    padding: const EdgeInsets.only(top: 10, left: 200, right: 200),
                    separatorBuilder: (BuildContext context, int index) => const Divider(),  
                    itemCount: frames.length,
                    itemBuilder: (context, index){
                      return ListTile(
                        onTap: () {},
                        title: Text("${frames[index]['frameNumber']}"),
                        trailing: const Icon(Icons.check),
                      );
                    }, 
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}