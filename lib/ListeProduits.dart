import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddProductScreen.dart';
import 'produit.dart';

class ListeProduits extends StatefulWidget {
  @override
  _ListeProduitsState createState() => _ListeProduitsState();
}

class _ListeProduitsState extends State<ListeProduits> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  List<Produit> produits = [];

  Future<void> fetchProducts() async {
    try {
      QuerySnapshot produitsSnapshot = await db.collection("produits").get();

      List<Produit> fetchedProducts = produitsSnapshot.docs
          .map((doc) => Produit.fromFirestore(doc))
          .toList();

      setState(() {
        produits = fetchedProducts;
      });
    } catch (e) {
      print('Error fetching products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching products. Please try again.'),
        ),
      );
    }
  }

  void editProduct(Produit produit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          onProductAdded: fetchProducts,
          db: db,
          isEditing: true,
          editedProduct: produit,
        ),
      ),
    );
  }

  Future<void> deleteProduct(Produit produit) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${produit.designation}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled the deletion
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true); // User confirmed the deletion

                // Delete the product directly using its Firestore document ID
                await db.collection("produits").doc(produit.firestoreDocumentId).delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product deleted successfully!'),
                  ),
                );

                // Refresh the list after deletion
                fetchProducts();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // User confirmed the deletion
    } else {
      // User canceled the deletion
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product list'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Add Product'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to the add product screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductScreen(
                      onProductAdded: fetchProducts,
                      db: db,
                      isEditing: false,
                      editedProduct: Produit(
                        id: 0,
                        marque: '',
                        designation: '',
                        categorie: '',
                        prix: 0.0,
                        photo: '',
                        quantite: 0,
                        firestoreDocumentId: '',
                      ),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('View Products'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // You are already on the view products screen
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Marque')),
                  DataColumn(label: Text('Designation')),
                  DataColumn(label: Text('Categorie')),
                  DataColumn(label: Text('Prix')),
                  DataColumn(label: Text('Photo')),
                  DataColumn(label: Text('Quantite')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: produits.map((produit) {
                  return DataRow(
                    cells: [
                      DataCell(Text(produit.marque)),
                      DataCell(Text(produit.designation)),
                      DataCell(Text(produit.categorie)),
                      DataCell(Text(produit.prix.toString())),
                      DataCell(Text(produit.photo)),
                      DataCell(Text(produit.quantite.toString())),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                editProduct(produit);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await deleteProduct(produit);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
