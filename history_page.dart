import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'history.dart';
import 'item.dart';


/*void main() {
  runApp(MyApp1());
}
class MyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyWidget(), // Your custom widget is now the home screen of the app.
    );
  }
}*/


class MyWidget extends StatefulWidget {
  final int itemId;

  // Constructor with itemId parameter
  MyWidget({Key? key, required this.itemId}) : super(key: key);

  @override
  _MyWidgetState createState() => _MyWidgetState(itemId: itemId);
}


class _MyWidgetState extends State<MyWidget> {
  // Example list of HistoryRecord

  final int itemId;

  _MyWidgetState({required this.itemId});

  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

  Item item = Item(
    itemId: -1, // Use default values that make sense for your application
    groupId: -1,
    itemName: 'Placeholder',
    color: 'grey',
    qty: 0,
    unit: '',
    itemlimit: 0,
    description: 'Loading...',
  );

  List<HistoryRecord> records = [
    HistoryRecord(itemId: 1, dateTime: "0000-00-00 00:00", updating: 1, qty: 10),
    // Add more HistoryRecord objects here
  ];

  void _loadItem() async {

    Item? tempItem = await DatabaseHelper.instance.getItem(itemId);
    if (tempItem != null) {
      setState(() {
        item = tempItem;
      });
    }

    List<HistoryRecord> tempHistoryRecords = await DatabaseHelper.instance.getHistoryForItem(itemId);
    setState(() {
      records =tempHistoryRecords.reversed.toList();
      print(records);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadItem();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Records'),
      ),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          HistoryRecord record = records[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date and Time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.dateTime.split(" ")[0]), // Date
                      Text(record.dateTime.split(" ")[1].substring(0,5)), // Time
                    ],
                  ),
                  // Item Name and Updating
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(item.itemName), // Item Name
                      Text(record.updating.toString()+' '+item.unit), // Updating
                    ],
                  ),
                  // Qty and Text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${record.qty}', style: TextStyle(fontSize : 20,color: Item.colorMap[item.color]),), // Qty
                      const Text('left'), // Some additional text
                    ],
                  ),
                  // Delete Button

                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      String dateTime = records[index].dateTime; // Get the dateTime of the record you want to delete

                      /*int newQ=item.qty-record.updating;
                      item = item.copyWith(qty: newQ);
                      int result = await databaseHelper.updateItemQty(item.itemId, newQ);*/

                      // Call the method to delete the record from the database
                      await databaseHelper.deleteHistoryRecordByDateTime(dateTime);

                      // Then remove the record from the list in the state and update the UI
                      setState(() {
                        records.removeAt(index); // Remove the record from the list
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}