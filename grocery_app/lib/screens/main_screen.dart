import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'firebase_service.dart'; // Import your Firebase service

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
        toolbarHeight: 80,
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
            Text(
              '  The Daily Mart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: _currentIndex == 0 ? _buildGroceryTab() : CartScreen(cartItems),
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
                label: 'Cart',
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

    return Column(
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
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _addToCart(currentItem);
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text('Add to Cart'),
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
    );
  }

  List<Item> cartItems = [];
  void _addToCart(Item item) {
    print(item.description);

    // Check if the item already exists in the cartItems list
    bool itemExists = cartItems.any((cartItem) => cartItem.name == item.name);

    if (itemExists) {
      // If the item exists, find it and increase the quantity
      Item existingItem =
          cartItems.firstWhere((cartItem) => cartItem.name == item.name);
      setState(() {
        existingItem.quantity++; // Increase the quantity
      });
    } else {
      // If the item doesn't exist, add it to the cartItems list
      setState(() {
        item.quantity = 1; // Set the initial quantity to 1
        cartItems.add(item);
      });
    }
    // Get the ScaffoldMessenger to show a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item added to cart'),
        duration: Duration(seconds: 2), // Set the duration for the SnackBar
      ),
    );
  }
}

// void _addToCart(Item item) {
//   print(item.description);

//   // Check if the item already exists in the cartItems list
//   bool itemExists = cartItems.any((cartItem) => cartItem.name == item.name);

//   if (itemExists) {
//     // If the item exists, find it and increase the quantity
//     Item existingItem =
//         cartItems.firstWhere((cartItem) => cartItem.name == item.name);
//     setState(() {
//       existingItem.quantity++; // Increase the quantity
//     });
//   } else {
//     // If the item doesn't exist, add it to the cartItems list
//     setState(() {
//       item.quantity = 1; // Set the initial quantity to 1
//       cartItems.add(item);
//     });
//   }

//   // Add your logic to handle adding the item to the cart
//   // For example, you can maintain a list of items in the cart
//   // and navigate to the CartScreen
// }
