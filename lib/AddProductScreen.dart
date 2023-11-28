import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'produit.dart';

class AddProductScreen extends StatefulWidget {
  final void Function() onProductAdded;
  final FirebaseFirestore db;
  final bool isEditing;
  final Produit editedProduct;

  const AddProductScreen({
    Key? key,
    required this.onProductAdded,
    required this.db,
    required this.isEditing,
    required this.editedProduct,
  }) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController marqueController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController categorieController = TextEditingController();
  final TextEditingController prixController = TextEditingController();
  final TextEditingController photoController = TextEditingController();
  final TextEditingController quantiteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      // Populate the text controllers with the existing values
      marqueController.text = widget.editedProduct.marque;
      designationController.text = widget.editedProduct.designation;
      categorieController.text = widget.editedProduct.categorie;
      prixController.text = widget.editedProduct.prix.toString();
      photoController.text = widget.editedProduct.photo;
      quantiteController.text = widget.editedProduct.quantite.toString();
    }
  }

  Future<void> addOrUpdateProduct() async {
    try {
      if (widget.isEditing) {
        // If editing, update the existing product using Firestore document ID
        await widget.db
            .collection("produits")
            .doc(widget.editedProduct.firestoreDocumentId)
            .update({
          'marque': marqueController.text,
          'designation': designationController.text,
          'categorie': categorieController.text,
          'prix': double.parse(prixController.text),
          'photo': photoController.text,
          'quantite': int.parse(quantiteController.text),
        });
      } else {
        // If adding, omit 'id' to let Firestore generate a unique ID
        await widget.db.collection("produits").add({
          'marque': marqueController.text,
          'designation': designationController.text,
          'categorie': categorieController.text,
          'prix': double.parse(prixController.text),
          'photo': photoController.text,
          'quantite': int.parse(quantiteController.text),
        });
      }

      // Show a success message or trigger any additional action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Product ${widget.isEditing ? 'updated' : 'added'} successfully!'),
        ),
      );

      // Clear the input fields
      marqueController.clear();
      designationController.clear();
      categorieController.clear();
      prixController.clear();
      photoController.clear();
      quantiteController.clear();

      // Trigger the function to fetch products
      widget.onProductAdded();
    } catch (e) {
      print('Error adding/updating product: $e');
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Error ${widget.isEditing ? 'updating' : 'adding'} product. Please check your input.'),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: marqueController,
              decoration: InputDecoration(labelText: 'Marque'),
            ),
            TextField(
              controller: designationController,
              decoration: InputDecoration(labelText: 'Designation'),
            ),
            TextField(
              controller: categorieController,
              decoration: InputDecoration(labelText: 'Categorie'),
            ),
            TextField(
              controller: prixController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Prix'),
            ),
            TextField(
              controller: photoController,
              decoration: InputDecoration(labelText: 'Photo URL'),
            ),
            TextField(
              controller: quantiteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantite'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed:
                  addOrUpdateProduct, // Call the function to add or update the product
              child: Text(widget.isEditing ? 'Update Product' : 'Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
