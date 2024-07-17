import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

import 'addbatch.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    DateFormat timeformat = DateFormat('HH:mm'); 
    DateFormat dateformat = DateFormat('dd-MM-yyyy');
    DateTime timenow = timeformat.parse(timeformat.format(DateTime.now()));
    DateTime datenow = dateformat.parse(dateformat.format(DateTime.now()));
    String greeting = '';
    if (timenow.hour < 12) {
      greeting = 'Good Morning!';
    } else if (timenow.hour < 18) {
      greeting = 'Good Afternoon!';
    } else {
      greeting = 'Good Evening!';
    }
    
    return ListView(
        padding: const EdgeInsets.all(50),
        shrinkWrap: false,
        children: [
          HeadingBox(
              greeting: greeting, dateformat: dateformat, datenow: datenow, timeformat: timeformat, timenow: timenow
            ),
          const SizedBox(height: 50),
          AddBatchForm(),
        ],
      );
  }
}

class HeadingBox extends StatelessWidget {
  const HeadingBox({
    super.key,
    required this.greeting,
    required this.dateformat,
    required this.datenow,
    required this.timeformat,
    required this.timenow,
  });

  final String greeting;
  final DateFormat dateformat;
  final DateTime datenow;
  final DateFormat timeformat;
  final DateTime timenow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[200],
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            child: Text(greeting, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            //color: Colors.grey[300],
            child: Text('${dateformat.format(datenow)}    ${timeformat.format(timenow)}', style: const TextStyle(fontSize: 18)),
          ),
        ]
      ),
    );
  }
}
