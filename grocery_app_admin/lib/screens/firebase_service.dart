import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  Future<List<Item>> getItems() async {
    List<Item> items = [];

    try {
      DatabaseEvent event = await _databaseReference.child('items').once();

      // Check for successful data retrieval
      if (event.snapshot.exists) {
        DataSnapshot snapshot = event.snapshot;

        // Access data from snapshot
        Map<dynamic, dynamic>? values = snapshot.value as Map?;

        if (values != null) {
          // Iterate through the values
          for (var entry in values.entries) {
            String itemId = entry.key; // Get the item ID
            Map<dynamic, dynamic> itemData =
                entry.value as Map<dynamic, dynamic>;

            // Create the Item object and add it to the list
            items.add(Item.fromMap(itemId, {
              'name': itemData['name'],
              'image': itemData['image'],
              'description': itemData['description'],
              'price': '${itemData['price']}',
              'quantity': 1
            }));
          }
        }
      } else {
        print("Failed to retrieve data");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }

    return items;
  }

  Future<bool> placeOrder(Map<String, dynamic> orderData) async {
    try {
      // Generate a unique key for the order
      String? orderKey = _databaseReference.child('orders').push().key;

      // Create a map to store the order details
      Map<String, dynamic> orderDetails = {
        'user': {
          'name': orderData['name'],
          'email': orderData['email'],
          'phoneNumber': orderData['phoneNumber'],
          'address': orderData['address'],
        },
        'orderItems': orderData['orderDetails'],
        'totalPrice': orderData['totalPrice'],
        'timestamp': ServerValue.timestamp,
        'status': 'Processing',
      };

      // Push the order details to the 'orders' node in the database
      await _databaseReference
          .child('orders')
          .child(orderKey!)
          .set(orderDetails);

      print('Order placed successfully!');
      return true;
    } catch (e) {
      print('Error placing order: $e');
      return false;
    }
  }

  Future<void> editItem(
      String itemId, Map<String, dynamic> updatedItemData) async {
    try {
      await _databaseReference
          .child('items')
          .child(itemId)
          .update(updatedItemData);
      print('Item edited successfully!');
    } catch (e) {
      print('Error editing item: $e');
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _databaseReference.child('items').child(itemId).remove();
      print('Item deleted successfully!');
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  Future<void> addItem(String itemName, String itemDescription,
      double itemPrice, File imageFile) async {
    try {
      // Upload the image to Firebase Storage
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() => null);

      // Get the URL of the uploaded image
      String imageUrl = await storageReference.getDownloadURL();

      // Add the item to the Firebase Realtime Database
      await _databaseReference.child('items').push().set({
        'name': itemName,
        'description': itemDescription,
        'price': itemPrice,
        'image': imageUrl,
      });

      print('Item added successfully!');
    } catch (e) {
      print('Error adding item: $e');
    }
  }

  Future<List<Order>> getOrders() async {
    List<Order> orders = [];

    try {
      DatabaseEvent event = await _databaseReference.child('orders').once();

      // Check for successful data retrieval
      if (event.snapshot.exists) {
        DataSnapshot snapshot = event.snapshot;

        // Access data from snapshot
        Map<dynamic, dynamic>? values = snapshot.value as Map?;

        if (values != null) {
          // Iterate through the values
          values.forEach((key, value) {
            // Assuming each order has an 'id' field in its data
            String orderId = key;
            Map<dynamic, dynamic> orderData = value as Map<dynamic, dynamic>;

            // Create the Order object and set the order ID
            Order order = Order.fromMap(orderData);
            order.id = orderId;

            // Add the order to the list
            orders.add(order);
          });
        }
      } else {
        print("Failed to retrieve orders data");
      }
    } catch (e) {
      print("Error fetching orders data: $e");
    }

    return orders;
  }

  Future<void> editOrderStatus(String orderId, String newStatus) async {
    try {
      await _databaseReference
          .child('orders')
          .child(orderId)
          .child('status')
          .set(newStatus);
      print('Order status edited successfully!');
    } catch (e) {
      print('Error editing order status: $e');
    }
  }
}

class Order {
  String id;
  String orderItems;
  String status;
  int timestamp;
  User user;

  Order({
    required this.id,
    required this.orderItems,
    required this.status,
    required this.timestamp,
    required this.user,
  });

  factory Order.fromMap(Map<dynamic, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      orderItems: map['orderItems'] ?? '',
      status: map['status'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      user: User.fromMap(map['user'] ?? {}),
    );
  }
}

class User {
  String name;
  String email;
  String phoneNumber;
  String address;

  User({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
  });

  factory User.fromMap(Map<dynamic, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
    );
  }
}

class Item {
  String id; // Add this field for the item ID
  String name;
  String image;
  String description;
  String price;
  int quantity;

  Item({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.price,
    required this.quantity,
  });

  factory Item.fromMap(String id, Map<dynamic, dynamic> map) {
    return Item(
      id: id,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '0', // Make sure to use a string for the price
      quantity: map['quantity'] ?? 1,
    );
  }
}
