import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    DateFormat timeformat = new DateFormat('HH:mm'); 
    DateFormat dateformat = new DateFormat('dd-MM-yyyy');
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
    
    return Row(
      children: <Widget>[
      HeadingBox(greeting: greeting, dateformat: dateformat, datenow: datenow, timeformat: timeformat, timenow: timenow),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[300],
            child: const Text('Hello World', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.grey[300],
            child: Text(greeting, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.grey[300],
          child: Text('${dateformat.format(datenow)} ${timeformat.format(timenow)}', style: TextStyle(fontSize: 18)),
        ),
      ]
    );
  }
}