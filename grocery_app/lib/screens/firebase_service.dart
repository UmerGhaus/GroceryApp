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
            Map<dynamic, dynamic> itemData =
                entry.value as Map<dynamic, dynamic>;

            // Create the Item object and add it to the list
            items.add(Item.fromMap({
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
}

class Item {
  String name;
  String image;
  String description;
  String price; // Add this property for the price
  int quantity;
  Item({
    required this.name,
    required this.image,
    required this.description,
    required this.price,
    required this.quantity,
  });

  factory Item.fromMap(Map<dynamic, dynamic> map) {
    return Item(
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
      quantity: map['quantity'] ?? 1,
    );
  }
}
