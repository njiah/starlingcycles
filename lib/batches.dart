import 'package:flutter/material.dart';
import 'database.dart';
import 'batchpage.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with TickerProviderStateMixin{
  List<Map<String, dynamic>> batches = [];
  final dbHelper = DatabaseHelper();
  List progress = ['Not Started', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _getBatches();
  }
  void _getBatches() async {
    final data = await dbHelper.query('Batch');
    setState(() {
      batches = data;
    });
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
            Material(
              child: Container(
                //color: Colors.white,
                margin: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                child: TabBar(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
                  unselectedLabelColor: Theme.of(context).colorScheme.primary,
                  labelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  tabs: [
                    Tab(
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                        ),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text('Not Started'),
                          ),
                        ),
                      ),
                     Tab(
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                        ),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text('In Progress'),
                          ),
                        ),
                      ),
                      Tab(
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                        ),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text('Completed'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: TabBarView(
              children: [
              for (var item in progress)
                FutureBuilder(
                  future: dbHelper.queryBatches(item),
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    else if (snapshot.hasError){
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    else {
                      final data = snapshot.data as List<Map<String, dynamic>>;
                      if (data.isEmpty) {
                        return Center(child: Text('$item Batches'));
                      }
                      else{
                        return ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: data.length,
                          itemBuilder: (context, index){
                            return BatchCard(batchname: data[index]['batchName'], manufacture: data[index]['manufacture']); 
                          }
                        );
                      }  
                    }
                  }
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BatchCard extends StatelessWidget{
  const BatchCard({super.key, required this.batchname, this.manufacture});
  final String batchname;
  final String? manufacture;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10, top: 10, left: 100, right: 100),
      color: Colors.grey[200],
      child: Container(
        padding: const EdgeInsets.all(10),
        child: ListTile(
          title:Text(batchname, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          subtitle: manufacture == null ? const Text('Manufacture: Not Set') : Text(manufacture!), 
          trailing: IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BatchPage(batchName: batchname),
                ),
              ).then((_){
                _triggerDataReload(context);
              });
            },
          ),
          leading: const Icon(Icons.pedal_bike_rounded, size: 40,),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BatchPage(batchName: batchname),
              ),
            ).then((_){
              _triggerDataReload(context);
            });
            
          },
        ),
      ),
    );
  }
}

//reload data after returning from batch page
void _triggerDataReload(BuildContext context){ 
  final progressPageState = context.findAncestorStateOfType<_ProgressPageState>();
  progressPageState?._getBatches();
}