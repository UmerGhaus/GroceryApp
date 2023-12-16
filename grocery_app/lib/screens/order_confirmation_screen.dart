// order_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'firebase_service.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final List<Item>
      cartItems; // Assuming Item is the data type for items in the cart

  // Constructor to receive cartItems
  OrderConfirmationScreen(this.cartItems);

  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Calculate total price
    int totalPrices = cartItems.fold(
        0,
        (previousValue, item) =>
            previousValue + (int.parse(item.price) * item.quantity));

    return Scaffold(
      backgroundColor: Color.fromRGBO(233, 246, 249, 1.0),
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Color.fromRGBO(70, 83, 199, 1.0),
        title: Text(
          ' Order Confirmation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Wrap the entire content in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Cart Items',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(),
              // Display details of each item in the cart
              ListView.builder(
                shrinkWrap: true,
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  Item item = cartItems[index];
                  return ListTile(
                    title: Text('${item.name} x${item.quantity}'),
                    subtitle: Text(
                        'Price: Rs. ${int.parse(item.price) * item.quantity}'),
                  );
                },
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
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
              Divider(),
              // Textboxes for user input (name, email, phone number, address)
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              phoneController.text.isEmpty ||
                              addressController.text.isEmpty) {
                            // Show SnackBar with an error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return; // Return early, don't proceed with placing the order
                          }
                          // Create a string representing the order details
                          String orderDetails = cartItems
                              .map((item) =>
                                  '${item.name},${item.quantity},${int.parse(item.price) * item.quantity}')
                              .join(':');

                          // Get user input
                          String name = nameController.text;
                          String email = emailController.text;
                          String phoneNumber = phoneController.text;
                          String address = addressController.text;

                          // Create a map with user and order information
                          Map<String, dynamic> orderData = {
                            'name': name,
                            'email': email,
                            'phoneNumber': phoneNumber,
                            'address': address,
                            'orderDetails': orderDetails,
                          };

                          // Implement the logic to place the order and push data to Firebase
                          bool orderPlaced =
                              await FirebaseService().placeOrder(orderData);

                          if (orderPlaced) {
                            // Show SnackBar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Order Placed Successfully!'),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // Delay the restart of the application
                            Future.delayed(Duration(seconds: 1), () {
                              // Pop all existing routes and push a new one
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/', (route) => false);
                            });
                          } else {
                            // Failed to place order
                            print('Failed to place order.');
                          }

                          // Print for demonstration purposes
                          print('Placing Order...');
                          print('Name: $name');
                          print('Email: $email');
                          print('Phone Number: $phoneNumber');
                          print('Address: $address');
                          print('Order Details: $orderDetails');
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
                          'Confirm Order',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}// order_confirmation_screen.dart
