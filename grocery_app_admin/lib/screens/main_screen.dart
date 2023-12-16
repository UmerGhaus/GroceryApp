import 'package:flutter/material.dart';
import 'package:grocery_app/screens/add_item_screen.dart';
import 'orders_screen.dart';
import 'firebase_service.dart'; // Import your Firebase service
import 'package:image_picker/image_picker.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late List<Item> _items = [];
  int _currentIndex = 0;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    print("Loading items...");
    try {
      List<Item> items = await _firebaseService.getItems();
      print("Items loaded successfully: $items");
      setState(() {
        _items = items;
      });
    } catch (e) {
      print("Error loading items: $e");
    }
  }

  List<Item> _searchResults = [];

  void _searchItems(String query) {
    setState(() {
      _searchResults = _items
          .where((item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(233, 246, 249, 1.0),
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: Color.fromRGBO(70, 83, 199, 1.0),
        title: const Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/logo.png'),
                radius: 30,
              ),
            ),
            Column(
              children: [
                Text(
                  '  The Daily Mart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '  Seller Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _currentIndex == 0 ? _buildGroceryTab() : OrdersScreen(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(70, 83, 199, 1.0),
            borderRadius: BorderRadius.circular(15),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.shop),
                label: 'Grocery',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Orders',
              ),
            ],
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            elevation: 0, // Remove the shadow
          ),
        ),
      ),
    );
  }

  Widget _buildGroceryTab() {
    List<Item> displayItems =
        _searchController.text.isEmpty ? _items : _searchResults;

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: _searchItems,
                decoration: InputDecoration(
                  hintText: 'Search items',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: displayItems.isNotEmpty
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: displayItems.length,
                      itemBuilder: (context, index) {
                        Item currentItem = displayItems[index];

                        return Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  currentItem.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rs. ${currentItem.price}',
                                      style: TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      currentItem.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      currentItem.description,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            _editItem(currentItem);
                                          },
                                          icon: Icon(Icons.edit),
                                          label: SizedBox.shrink(),
                                          style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.black,
                                            padding: EdgeInsets.all(
                                                8.0), // Add padding for space
                                          ),
                                        ),
                                        SizedBox(width: 16.0),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            _deleteItem(currentItem);
                                          },
                                          icon: Icon(Icons.delete),
                                          label: SizedBox.shrink(),
                                          style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.black,
                                            padding: EdgeInsets.all(
                                                8.0), // Add padding for space
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
                      },
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ],
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton(
            onPressed: () async {
              // Navigate to the AddItemScreen and wait for it to complete
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemScreen()),
              );

              // Reload items after the AddItemScreen is closed
              await _loadItems();
            },
            child: Icon(Icons.add),
            backgroundColor: Color.fromRGBO(70, 83, 199, 1.0),
          ),
        ),
      ],
    );
  }

  List<Item> cartItems = [];
  void _editItem(Item item) {
    // Open a dialog to allow the user to edit item details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController =
            TextEditingController(text: item.name);
        TextEditingController descriptionController =
            TextEditingController(text: item.description);
        TextEditingController priceController =
            TextEditingController(text: item.price);

        return AlertDialog(
          title: Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Call the editItem method to update the item in Firebase
                await _firebaseService.editItem(item.id, {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price': priceController.text,
                });

                // Reload the items after editing
                await _loadItems();

                Navigator.of(context).pop(); // Close the dialog

                // Show a SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Item edited successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(Item item) async {
    String itemId = _items.firstWhere((element) => element == item).id;
    _firebaseService.deleteItem(itemId);
    // Refresh the UI or perform any other necessary actions after deletion
    // Refresh the UI by loading the items again
    await _loadItems();
    // Show a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item deleted successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
