import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all recipes stream
  Stream<List<RecipeModel>> getRecipesStream() {
    return _firestore
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecipeModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get recipes by user
  Stream<List<RecipeModel>> getUserRecipesStream(String userId) {
    return _firestore
        .collection('recipes')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecipeModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get single recipe
  Future<RecipeModel?> getRecipe(String recipeId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('recipes').doc(recipeId).get();
      if (doc.exists) {
        return RecipeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting recipe: $e');
      return null;
    }
  }

  // Add new recipe
  Future<String?> addRecipe({
    required String title,
    required String description,
    required List<String> ingredients,
    required String cookingTime,
    required File imageFile,
    required String authorId,
    required String authorName,
  }) async {
    try {
      // Upload image to Firebase Storage
      String imageUrl = await _uploadImage(imageFile);

      // Add recipe to Firestore
      DocumentReference docRef = await _firestore.collection('recipes').add({
        'title': title,
        'description': description,
        'ingredients': ingredients,
        'cookingTime': cookingTime,
        'imageUrl': imageUrl,
        'authorId': authorId,
        'authorName': authorName,
        'likes': 0,
        'likedBy': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error adding recipe: $e');
      return null;
    }
  }

  // Update recipe
  Future<bool> updateRecipe({
    required String recipeId,
    required String title,
    required String description,
    required List<String> ingredients,
    required String cookingTime,
    File? imageFile,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'title': title,
        'description': description,
        'ingredients': ingredients,
        'cookingTime': cookingTime,
      };

      // Upload new image if provided
      if (imageFile != null) {
        String imageUrl = await _uploadImage(imageFile);
        updateData['imageUrl'] = imageUrl;
      }

      await _firestore.collection('recipes').doc(recipeId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating recipe: $e');
      return false;
    }
  }

  // Delete recipe
  Future<bool> deleteRecipe(String recipeId) async {
    try {
      await _firestore.collection('recipes').doc(recipeId).delete();
      return true;
    } catch (e) {
      print('Error deleting recipe: $e');
      return false;
    }
  }

  // Toggle like on recipe
  Future<bool> toggleLike(String recipeId, String userId) async {
    try {
      DocumentReference recipeRef = _firestore.collection('recipes').doc(recipeId);
      
      return await _firestore.runTransaction<bool>((transaction) async {
        DocumentSnapshot recipeDoc = await transaction.get(recipeRef);
        
        if (!recipeDoc.exists) {
          throw Exception('Recipe does not exist!');
        }

        Map<String, dynamic> recipeData = recipeDoc.data() as Map<String, dynamic>;
        List<String> likedBy = List<String>.from(recipeData['likedBy'] ?? []);
        int likes = recipeData['likes'] ?? 0;

        if (likedBy.contains(userId)) {
          // Unlike
          likedBy.remove(userId);
          likes--;
        } else {
          // Like
          likedBy.add(userId);
          likes++;
        }

        transaction.update(recipeRef, {
          'likes': likes,
          'likedBy': likedBy,
        });

        return true;
      });
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  // Search recipes
  Stream<List<RecipeModel>> searchRecipes(String query) {
    return _firestore
        .collection('recipes')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: '$query\uf8ff')
        .orderBy('title')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecipeModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = 'recipes/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }
} 