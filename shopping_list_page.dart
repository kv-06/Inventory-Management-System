import 'package:flutter/material.dart';
import 'package:invent/database/database_helper.dart';



class ShoppingListPage extends StatefulWidget {
  final int userId;

  const ShoppingListPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState(userId: userId);
}


class _ShoppingListPageState extends State<ShoppingListPage> {
  /*List<ListItem> itemsList = [
    ListItem(itemId: 1, itemName: 'Apple', unit: 'pieces', qtyToBuy: 5),
    ListItem(itemId: 2, itemName: 'Banana', unit: 'pieces'),
    ListItem(itemId: 3, itemName: 'Cherry', unit: 'pieces', qtyToBuy: 10),
  ];*/

  final int userId;

  _ShoppingListPageState({required this.userId});
  int selected_index=1;

  List<ListItem> itemsList = [];

  @override
  void initState() {
    super.initState();
    loadShoppingList();
  }

  Future<void> loadShoppingList() async {
    print(userId);
    List<Map<String, dynamic>> shoppingList =
    await DatabaseHelper.instance.getShoppingListByUserId(userId);
    print(shoppingList);

    setState(() {
      itemsList = shoppingList
          .map((item) =>
          ListItem(
            itemId: item['item_id'],
            itemName: item['item_name'],
            unit: '',
            // Add the appropriate column name from your database
            qtyToBuy: item['qty_to_buy'].toDouble(),
            //isChecked: item['checked'] == 1,
          ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Shopping List'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                _showAddItemDialog();
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: itemsList.map((e) => ShoppingList(listItem: e,delete: (){
              setState(() {
                itemsList.remove(e);
                //code to remove from db also
              });
            },)).toList(),
          ),
        ),

      );
  }

  Future<void> _showAddItemDialog() async {
    TextEditingController itemNameController = TextEditingController();
    TextEditingController qtyToBuyController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Builder(
          builder: (context) {
            return AlertDialog(
              title: Text('Add Item'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: itemNameController,
                      decoration: InputDecoration(labelText: 'Item Name'),
                    ),
                    TextField(
                      controller: qtyToBuyController,
                      decoration: InputDecoration(labelText: 'Quantity to Buy'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Insert the item into the shopping list
                    int? itemId = await DatabaseHelper.instance.getItemIdByName(itemNameController.text);
                    if(itemId==null){itemId=0;}
                    await DatabaseHelper.instance.insertItemIntoShoppingList(
                      userId,

                      //change this to get itemid from items table
                      itemId,
                      // You can use a unique identifier for the item_id
                      itemNameController.text,
                      double.parse(qtyToBuyController.text),
                      0, // Initially unchecked
                    );

                    // Reload the shopping list
                    await loadShoppingList();

                    Navigator.of(context).pop();
                  },
                  child: Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}

class ShoppingList extends StatefulWidget {
  final ListItem listItem;

  final VoidCallback delete;

  ShoppingList({required this.listItem, required this.delete});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  @override
  Widget build(BuildContext context) {
    final item = widget.listItem;

    return Dismissible(
      key: Key(item.itemName),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.green,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) async {
          // Handle dismiss
          // Here, you can add more logic based on the direction (left or right swipe)
          if (direction == DismissDirection.startToEnd) {
            // Left swipe (delete)

            await DatabaseHelper.instance.deleteItem(item.itemId);
            widget.delete();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.itemName} deleted')),
            );
          } else if (direction == DismissDirection.endToStart) {
            // Right swipe (check)

            await DatabaseHelper.instance.addItemQty(item.itemId, item.qtyToBuy);
            await DatabaseHelper.instance.deleteItem(item.itemId);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.itemName} added')),
            );
          }
      },
      child: CheckboxListTile(
        title: Text(item.itemName),
        subtitle: item.qtyToBuy != null
            ? Text('Quantity to buy: ${item.qtyToBuy}')
            : null,
        value: item.isChecked,
        onChanged: (bool? value) {
          setState(() {
            item.isChecked = value!;
          });
        },
      ),
    );
  }
}

class ListItem {
  final int itemId;
  final String itemName;
  final String unit;
  double? qtyToBuy;
  bool isChecked;

  ListItem({
    required this.itemId,
    required this.itemName,
    required this.unit,
    this.qtyToBuy,
  }) : isChecked = false;
}
