//import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
//import 'package:flutter/services.dart' show rootBundle;
//import 'package:sqflite/sqflite.dart'; 
import 'database.dart';
import 'home.dart';
import 'batchpage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Starling Cycles',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Starling Cycles'),
    );
  }
}

class MyHomePage extends StatefulWidget{
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomePage(),
    const ProgressPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,

        //title: Text(widget.title),
        title: SizedBox(
          width: 180,
          child: Image.asset('images/logo.png'),
        ),
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}


class BatchCard extends StatelessWidget{
  const BatchCard({required this.batchname});
  final String batchname;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: SizedBox(
        height: 100,
        child: Card(
          child: Center(
            child: Text(batchname, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BatchPage(batchName: batchname),
          ),
        );
      },
    );
  }
}

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<Map<String, dynamic>> batches = [];
  final dbHelper = DatabaseHelper();

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
    return FutureBuilder(
      future: dbHelper.query('Batch'),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error'),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: Text('No Data'),
          );
        }
        final item = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(50),
          itemBuilder: (context, index) {
            return BatchCard(batchname: item[index]['batchName'] as String);
          },
          itemCount: item.length,
        );
      }
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Page'),
    );
  }
}
