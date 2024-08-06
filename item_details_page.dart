import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'history.dart';
import 'history_page.dart';
import 'item.dart';

void main(){
  runApp(MyApp(itemId: 1001,userId: 1,));
}

class MyApp extends StatefulWidget {
  final int itemId;
  final int userId;

  // Constructor with itemId parameter
  const MyApp({Key? key, required this.itemId, required this.userId}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState(itemId: itemId,userId: userId);
}


class _MyAppState extends State<MyApp>{

  //final List<Map<String, String>> sampleData =
  final int itemId;

  final int userId;
  _MyAppState({required this.itemId,required this.userId});

  Map<String, Color> colorMap = Item.colorMap;

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


  TextEditingController _controller = TextEditingController(text: '1');
  TextEditingController _controller2 = TextEditingController(text: '0');

  void _loadItem() async {

    Item? tempItem = await DatabaseHelper.instance.getItem(itemId);
    if (tempItem != null) {
      setState(() {
        // Safely update the state with the retrieved item
        item = tempItem;
        _controller2.text = item.qty.toString();
      });

      List<HistoryRecord> tempHistoryRecords = await DatabaseHelper.instance.getHistoryForItem(itemId);
      setState(() {
        records =tempHistoryRecords.reversed.toList();
      });

    }


  }

  @override
  void initState() {
    super.initState();
    _loadItem();

  }

  /*void _navigateAndPerformAction() async {
    // Navigate to Widget2 and wait for it to pop
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyWidget()),
    );

    _loadItem();
  }*/

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)  {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.itemName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 34.0, color: Colors.white),
                  ),
                ),

                //Spacer(),
                const SizedBox(width: 10),
                Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyWidget(itemId: itemId,)),
                      );
                      print('History Button pressed');
                    },
                    child: const Icon(Icons.access_time_outlined),
                  ),
                )
              ],
            ),
            backgroundColor: colorMap[item.color],// Optional: Customize AppBar color
          ),
          // Optional: Add body content here
          body: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjust space distribution
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // Use minimal space for the column
                              children: <Widget>[
                                const Text(
                                  'Group',
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center, // Center align text within the column
                                  style: TextStyle(fontSize: 20.0, ),
                                ),
                                Text(
                                  item.groupId.toString(), // Second text in the column
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center, // Center align text within the column
                                  style: TextStyle(fontSize: 26.0, color: colorMap[item.color]),
                                ),
                              ],
                            ),
                          ),
                          // Vertical Divider
                          const VerticalDivider(
                            color: Colors.black,
                            thickness: 1, // Thickness of the line
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // Use minimal space for the column
                              children: <Widget>[
                                const Text(
                                  'Min',
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center, // Center align text within the column
                                  style: TextStyle(fontSize: 20.0, ),
                                ),
                                Text(
                                  item.itemlimit.toString(), // Second text in the column
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center, // Center align text within the column
                                  style: TextStyle(fontSize: 26.0, color: colorMap[item.color]),
                                ),
                              ],
                            ),
                          ),
                          // Another Vertical Divider
                          const VerticalDivider(
                            color: Colors.black,
                            thickness: 5, // Thickness of the line
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // Use minimal space for the column
                              children: <Widget>[
                                const Text(
                                  'Unit',
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center, // Center align text within the column
                                  style: TextStyle(fontSize: 20.0, ),
                                ),
                                Text(
                                  item.unit, // Second text in the column
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center, // Center align text within the column
                                  style: TextStyle(fontSize: 26.0, color: colorMap[item.color]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Aligns the Row's children to the start of the Row
                        children: <Widget>[

                          const Text('Add/Reduce by  ', // The text on the left
                            style: TextStyle(fontSize: 22),
                          ),
                          Container(
                              width: 80, height: 40,
                              child: TextField(
                                controller: _controller,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  //contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                                  //border: OutlineInputBorder(),

                                ),
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: 20.0, // Change font size here
                                ),
                              )
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.all(8.0), // Adds padding around the Row inside the Container
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distributes the buttons evenly across the Row
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () async{
                                DateTime now = DateTime.now();
                                String curDtTm = now.toString();
                                int newQ=int.parse(_controller2.text)-int.parse(_controller.text);

                                if (newQ<0){
                                  return;
                                }

                                if (newQ<item.itemlimit){

                                  await DatabaseHelper.instance.insertItemIntoShoppingList(
                                    userId,

                                    //change this to get itemid from items table
                                    itemId,
                                    // You can use a unique identifier for the item_id
                                    item.itemName,
                                    (item.itemlimit-newQ) as double,
                                    0, // Initially unchecked
                                  );
                                }

                                int result = await databaseHelper.updateItemQty(item.itemId, newQ);
                                item = item.copyWith(qty: newQ);

                                HistoryRecord h = HistoryRecord(
                                    itemId: item.itemId,
                                    dateTime: curDtTm,
                                    updating: -int.parse(_controller.text),
                                    qty: newQ
                                );

                                await databaseHelper.insertHistoryRecord(h);

                                setState(() {
                                  _controller2.text = newQ.toString();
                                });

                                print('Reduce Button pressed');
                              },
                              child: Icon(Icons.remove,),
                              style: ElevatedButton.styleFrom(
                                primary: colorMap[item.color], // Background color
                                onPrimary: Colors.white, // Text color (Foreground color)
                              ),
                            ),
                            Container(
                                width: 160,
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  controller: _controller2,
                                  decoration: InputDecoration(
                                    hintText: '',
                                  ),
                                  style: TextStyle(
                                    fontSize: 30.0, // Change font size here
                                  ),
                                )
                            ),
                            ElevatedButton(
                              onPressed: () async{
                                DateTime now = DateTime.now();
                                String curDtTm = now.toString();
                                int newQ=int.parse(_controller2.text)+int.parse(_controller.text);

                                if (newQ<0){
                                  return;
                                }

                                if (newQ<item.itemlimit){
                                  await DatabaseHelper.instance.insertItemIntoShoppingList(
                                    userId,

                                    //change this to get itemid from items table
                                    itemId,
                                    // You can use a unique identifier for the item_id
                                    item.itemName,
                                    (item.itemlimit-newQ) as double,
                                    0, // Initially unchecked
                                  );
                                }

                                int result = await databaseHelper.updateItemQty(item.itemId, newQ);
                                item = item.copyWith(qty: newQ);
                                HistoryRecord h = HistoryRecord(
                                    itemId: item.itemId,
                                    dateTime: curDtTm,
                                    updating: int.parse(_controller.text),
                                    qty: newQ
                                );

                                await databaseHelper.insertHistoryRecord(h);

                                setState(() {
                                  _controller2.text = newQ.toString();
                                });

                                print('Add Button pressed');
                              },
                              child: Icon(Icons.add,),
                              style: ElevatedButton.styleFrom(
                                primary: colorMap[item.color], // Background color
                                onPrimary: Colors.white, // Text color (Foreground color)
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text("Notes", style: TextStyle(fontSize : 19)),
                      Text('  ${item.description}', style: const TextStyle(fontSize : 16),
                        maxLines: 3, overflow: TextOverflow.ellipsis,),

                      /*CustomDropdownButton(title : 'This Year',
                  dropdownContent : HistoryListView(item: this.item, records: this.records)
                ),*/


                    ],
                  )
              )
          )
      ),
    );
  }
}

class CustomDropdownButton extends StatefulWidget {
  final String title;
  final Widget dropdownContent;

  CustomDropdownButton({required this.title, required this.dropdownContent});

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  bool _isExpanded = false;

  void _toggleDropdown() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: Text(widget.title),
          trailing: IconButton(
            icon: Icon(_isExpanded ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: _toggleDropdown,
          ),
          onTap: _toggleDropdown,
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          height: _isExpanded ? null : 0,
          child: ClipRect( // Add this ClipRect
            child: Container(
              padding: EdgeInsets.all(20),
              color: Colors.grey[200],
              child: widget.dropdownContent,
            ),
          ),
        ),
      ],
    );
  }
}