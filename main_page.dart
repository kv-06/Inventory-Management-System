import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:invent/item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'group.dart';
import 'item_details_page.dart'; //



/*void main() {
  //sqfliteFfiInit();
  // Set the databaseFactory to databaseFactoryFfi
  //databaseFactory = databaseFactoryFfi;
  //databaseFactory = databaseFactoryFfi();
  runApp(const MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
  ));
}*/

class HomePage extends StatefulWidget {

  final int userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState(userId: userId);
}

class _HomePageState extends State<HomePage> {
  List<String> groups = [];
  final int userId;

  _HomePageState({required this.userId});

  // Map to store items for each group
  Map<String, List<Item>> itemsMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Inventory"),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  //color: Colors.grey,
                  color: Color(int.parse('9EAEBBFF', radix: 16)),
                  height: 50,
                  child: const Text(
                    "   Your categories",
                    style: TextStyle(
                      fontSize: 35,
                    ),
                  ),
                ),
              ),
              Container(
                height: 50,
                decoration:  BoxDecoration(
                  //color: Colors.grey,
                  color: Color(int.parse('9EAEBBFF', radix: 16)),
                ),
                child: IconButton(
                  onPressed: () {
                    _showAddGroupDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  iconSize: 40,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Groups>>(
              future: DatabaseHelper.instance.getGroups(), // Fetch groups from the database
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final groups = snapshot.data!;
                  return Container(
                      height: 200,
                      child: ListView.builder(
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Card(
                                color: Colors.lightBlue,
                                child: ListTile(
                                  title: Text(group.grp_name),
                                  trailing: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (String value) {
                                      switch (value) {
                                        case 'add':
                                          _showAddItemDialog(context, group);
                                          break;
                                        case 'edit':
                                          _editGroup(context, group);
                                          break;
                                        case 'delete':
                                          _deleteGroup(context, group);
                                          break;
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'add',
                                        child: Text('Add'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Add item cards here
                              FutureBuilder<List<Item>>(
                                future: DatabaseHelper.instance.getItemsByGroupId(group.grp_id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    final items = snapshot.data!;
                                    return Column(
                                      children: items.map((item) {
                                        return _buildItemCard(context, item);
                                      }).toList(),
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      )

                  );
                }
              },
            ),
          )


        ],
      ),
    );
  }

  /*Widget _buildGroupCard(BuildContext context, Groups grp) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(grp.grp_name),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (String value) {
                switch (value) {
                  case 'add':
                    _showAddItemDialog(context, groupName);
                    break;
                  case 'edit':
                    _editGroup(context, groupName);
                    break;
                  case 'delete':
                    _deleteGroup(groupName);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'add',
                  child: Text('Add'),
                ),
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: itemsMap[groupName]?.length ?? 0,
              itemBuilder: (context, index) {
                final item = itemsMap[groupName]![index];
                return _buildItemCard(context, item);
              },
            ),
          ),
        ],
      ),
    );
  } */

  void _editGroup(BuildContext context, Groups grp) {
    TextEditingController newGroupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Group'),
          content: TextField(
            controller: newGroupNameController,
            decoration: const InputDecoration(hintText: 'Enter new group name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                String newGroupName = newGroupNameController.text.trim();
                if (newGroupName.isNotEmpty) {
                  // Update group name in the database
                  grp.grp_name = newGroupName;
                  await DatabaseHelper.instance.updateGroup(grp);

                  // Update UI if necessary
                  setState(() {});

                  Navigator.pop(context); // Close the dialog
                } else {
                  // Show an error indicating that the new group name cannot be empty
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('New group name cannot be empty'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.pop(dialogContext); // Close the dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }


  void _deleteGroup(BuildContext context, Groups grp) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this group?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
                child: Text('Delete'),
                onPressed: () async {
                  await DatabaseHelper.instance.deleteGroup(grp.grp_id);
                  setState(() {
                    // Update the UI if necessary
                    Navigator.of(context).pop(true);
                  });
                }

            ),
          ],
        );
      },
    );

    // Delete group if confirmed
    if (confirmDelete == true) {
      // Call the deleteGroup method from DatabaseHelper
      await DatabaseHelper.instance.deleteGroup(grp.grp_id);
      // Update UI or perform any other necessary actions
    }
  }


  void _addGroup(String groupName) {
    setState(() {
      groups.add(groupName);
    });
  }

  void _showAddGroupDialog(BuildContext context) {
    TextEditingController groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Group'),
          content: TextField(
            controller: groupNameController,
            decoration: const InputDecoration(hintText: 'Enter group name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                String groupName = groupNameController.text.trim();
                if (groupName.isNotEmpty) {
                  // Here you can add the group to your database or perform any other actions
                  // For demonstration, let's just print the group name
                  final newgrp  = Groups( grp_name: groupName, grp_id: Groups.lastgrpid++, user_id: 12);
                  int result = await DatabaseHelper.instance.insertGrp(newgrp);
                  print('Inserted $result records.');
                  _addGroup(groupName);
                  print(groups);
                  //Future<int> insertResult  = DatabaseHelper.instance.insertGrp(
                  //{ "user_id" : 12,"grp_name" : groupName});


                  if(result != -1 ){
                    print("The grp has been created");
                  }
                  print('New Group Name: $groupName');
                  Navigator.pop(context); // Close the dialog
                } else {
                  // Show an alert dialog with the error message
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Group name cannot be empty'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }


  Widget _buildItemCard(BuildContext context, Item item) {
    return Container(
      width: 400, // Adjust the width of the card as needed
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        //color: Colors.cyan,
        color: Color(int.parse('3B5CCCFF', radix: 16)),
        //color: Color(int.parse('517ABDFF', radix: 16)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.itemName),
              const SizedBox(height: 4),
              Text('Qty: ${item.qty} ${item.unit}'),
            ],
          ),
          onTap: () {
            // Handle tap on item card
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp(itemId: item.itemId,userId: userId,)),
            );}
      ),
    );
  }





  void _editItem(Item item) {
    // Implement editing functionality for the item
  }

  void _deleteItem(Item item) {
    // Implement deleting functionality for the item
  }

  void _showAddItemDialog(BuildContext context, Groups group) {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController unitController = TextEditingController();
    TextEditingController limitController = TextEditingController();
    TextEditingController colorController = TextEditingController();
    TextEditingController despController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Item Name',
                  ),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Quantity',
                  ),
                ),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    hintText: 'Unit',
                  ),
                ),
                TextField(
                  controller: limitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Limits',
                  ),
                ),
                TextField(
                  controller: colorController,
                  decoration: const InputDecoration(
                    hintText: 'Color',
                  ),
                ),
                TextField(
                  controller: despController,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String name = nameController.text.trim();
                    int quantity = int.tryParse(quantityController.text) ?? 0;
                    String unit = unitController.text.trim();
                    int limit = int.tryParse(limitController.text) ?? 0;

                    if (name.isNotEmpty && quantity > 0) {
                      final Item newItem = Item(
                        color: colorController.text.trim(),
                        groupId: group.grp_id,
                        itemId: Item.lastItemid++, // Assuming this value should be unique
                        itemName: name,
                        qty: quantity,
                        unit: unit,
                        itemlimit: limit,
                        description: despController.text.trim(),
                      );

                      int newItemId = await DatabaseHelper.instance.insertItem(newItem);
                      // Perform any additional logic if needed
                      Navigator.of(context).pop(); // Close the dialog
                      setState(() {

                      });
                    } else {
                      // Show an error dialog if any field is empty or quantity is invalid
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: const Text('Please fill all required fields correctly.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the error dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text('Add Item'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }





}