import 'package:flutter/material.dart';
import 'firebase_service.dart'; // Import your Firebase service

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late List<Order> _orders = []; // Initialize the list
  String? selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      List<Order> orders = await _firebaseService.getOrders();
      setState(() {
        _orders = orders;
      });
    } catch (e) {
      print('Error loading orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(233, 246, 249, 1.0),
      body: _buildOrdersList(),
    );
  }

  Widget _buildOrdersList() {
    List<Order> filteredOrders = _orders;

    // Apply filter if a status is selected
    if (selectedStatusFilter != null) {
      filteredOrders = _orders
          .where((order) => order.status == selectedStatusFilter)
          .toList();
    }

    if (filteredOrders.isEmpty) {
      // If there are no orders, show a message
      return Center(child: Text('No orders available.'));
    } else {
      // If there are orders, display them in a list
      return ListView.builder(
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          Order order = filteredOrders[index];

          return Card(
            color: Color.fromRGBO(204, 235, 241, 1), // Set background color
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(
                  10, 5, 10, 5), // Adjust content padding as needed
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID: ${order.id}',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Customer Name: ${order.user.name}',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
              subtitle: Text(
                'Status: ${order.status}',
                style: TextStyle(fontSize: 16.0), // Set the text size
              ),
              onTap: () async {
                // Show dialog with order information
                await _showOrderDialog(order);
              },
              // Additional content in the ListTile
              trailing: Icon(Icons.arrow_forward),
            ),
          );
        },
      );
    }
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<void> _showOrderDialog(Order order) async {
    // List of order statuses, you can customize this based on your status options
    List<String> orderStatusOptions = [
      'Processing',
      'Out for Delivery',
      'Delivered',
      'Cancelled'
    ];

    String selectedStatus = order.status; // Set to a valid initial value
    // Current order status

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Details',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Price
                Text('Order ID ${order.id}', style: TextStyle(fontSize: 18.0)),
                Divider(),
                // Order Items
                Text('Order Items:', style: TextStyle(fontSize: 18.0)),
                _buildOrderItemsList(order.orderItems),
                Divider(), // Add a divider

                // Customer Details
                Text('Name: ${order.user.name}',
                    style: TextStyle(fontSize: 17.0)),
                Text('Email: ${order.user.email}',
                    style: TextStyle(fontSize: 17.0)),
                Text('Phone #: ${order.user.phoneNumber}',
                    style: TextStyle(fontSize: 17.0)),
                Text('Address: ${order.user.address}',
                    style: TextStyle(fontSize: 17.0)),
                Divider(), // Add a divider

                // Total Price
                Text(
                    'Total Price: Rs. ${calculateTotalPrice(order.orderItems)}',
                    style: TextStyle(fontSize: 18.0)),
                Divider(), // Add a divider

                // Order Status
                Text('Order Status:', style: TextStyle(fontSize: 20.0)),
                DropdownButton<String>(
                  key: _formKey,
                  value: selectedStatus,
                  onChanged: (String? newValue) async {
                    setState(() {
                      selectedStatus = newValue!;
                    });

                    // Force a rebuild of the DropdownButton
                    _formKey.currentState?.setState(() {});

                    // Update the order status in Firebase
                    try {
                      await _firebaseService.editOrderStatus(
                          order.id, newValue!);
                      print('Order status edited successfully!');
                      // Show a SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Order Status changed successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context).pop(); // Close the dialog
                      // Reload orders after the dialog is closed
                      await _loadOrders();
                    } catch (e) {
                      print('Error editing order status: $e');
                      // Handle the error, e.g., show an error message to the user
                    }
                    //Navigator.of(context).pop();
                  },
                  items: orderStatusOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                // Reload orders after the dialog is closed
                await _loadOrders();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderItemsList(String orderItems) {
    // Split the order items string and create a list
    List<String> items = orderItems.split(':');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        // Split each item into name, quantity, and price
        List<String> itemDetails = item.split(',');

        return ListTile(
          title: Text('Item: ${itemDetails[0]}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quantity: ${itemDetails[1]}'),
              Text('Price: Rs. ${itemDetails[2]}'),
            ],
          ),
        );
      }).toList(),
    );
  }

  double calculateTotalPrice(String orderItems) {
    double totalPrice = 0.0;

    // Split the order items string into a list of items
    List<String> items = orderItems.split(':');

    for (var orderItem in items) {
      List<String> parts = orderItem.split(',');
      if (parts.length == 3) {
        // Assuming parts[2] is the price
        double price = double.tryParse(parts[2]) ?? 0.0;
        totalPrice += price;
      }
    }

    return totalPrice;
  }
}
