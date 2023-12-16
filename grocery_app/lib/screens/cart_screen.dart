import 'package:flutter/material.dart';
import 'order_confirmation_screen.dart';
import 'firebase_service.dart'; // Import your Firebase service

class CartScreen extends StatefulWidget {
  final List<Item> cartItems;

  CartScreen(this.cartItems);

  @override
  _CartScreenState createState() => _CartScreenState(cartItems);
}

class _CartScreenState extends State<CartScreen> {
  List<Item> cartItems; // Declare cartItems in _CartScreenState

  // Constructor to receive cartItems
  _CartScreenState(this.cartItems);
  @override
  Widget build(BuildContext context) {
    // Calculate total price
    int totalPrices = widget.cartItems.fold(
        0,
        (previousValue, item) =>
            previousValue + (int.parse(item.price) * item.quantity));

    return Scaffold(
      backgroundColor: Color.fromRGBO(233, 246, 249, 1.0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Display the names, images, and prices of items in the cart as cards
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  Item item = widget.cartItems[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Display item image on the left
                          Image.network(
                            item.image,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 16),
                          // Display item name, description, and price in the middle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display item name
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                // Display item description
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                                // Display item price
                                Text(
                                  'Price: Rs. ${int.parse(item.price) * item.quantity}',
                                  style: TextStyle(
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          // Add minus, add, and quantity labels on the right
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  // Decrease the quantity of the item
                                  setState(() {
                                    item.quantity--;
                                    if (item.quantity <= 0) {
                                      widget.cartItems.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  // Increase the quantity of the item
                                  setState(() {
                                    item.quantity++;
                                  });
                                },
                              ),
                              Text(
                                'Quantity: ${item.quantity}',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            // Display total prices and place order button at the bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
              child: Align(
                alignment:
                    Alignment.centerRight, // Align the content to the right
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end, // Align text to the right
                  children: [
                    Text(
                      'Total Prices: Rs. $totalPrices',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Implement the logic to place the order
                        // This could involve sending the order to a server, updating the database, etc.
                        print('Placing Order...');

                        // Navigate to OrderConfirmationScreen and pass the cartItems
                        if (cartItems.isNotEmpty) {
                          // Navigate to OrderConfirmationScreen and pass the cartItems
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderConfirmationScreen(cartItems),
                            ),
                          );
                        } else {
                          // Get the ScaffoldMessenger to show a SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Add Item to cart first.'),
                              duration: Duration(
                                  seconds:
                                      2), // Set the duration for the SnackBar
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        fixedSize:
                            MaterialStateProperty.all(Size.fromWidth(200.0)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromRGBO(70, 83, 199, 1.0)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: Text(
                        'Place Order',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
