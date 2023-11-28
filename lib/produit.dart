import 'package:cloud_firestore/cloud_firestore.dart';

class Produit {
  int id;
  String marque;
  String designation;
  String categorie;
  double prix;
  String photo;
  int quantite;
  String firestoreDocumentId; // Add this line

  Produit({
    required this.id,
    required this.marque,
    required this.designation,
    required this.categorie,
    required this.prix,
    required this.photo,
    required this.quantite,
    required this.firestoreDocumentId, // Add this line
  });

  // Factory constructor to create a Produit instance from a Firestore document
  factory Produit.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Produit(
      id: data['id'] ?? 0,
      marque: data['marque'] ?? '',
      designation: data['designation'] ?? '',
      categorie: data['categorie'] ?? '',
      prix: data['prix'] ?? 0.0,
      photo: data['photo'] ?? '',
      quantite: data['quantite'] ?? 0,
      firestoreDocumentId: doc.id, // Set the Firestore document ID
    );
  }
}
