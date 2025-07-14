import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final String cookingTime;
  final String imageUrl;
  final String authorId;
  final String authorName;
  final int likes;
  final List<String> likedBy;
  final DateTime createdAt;

  RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.cookingTime,
    required this.imageUrl,
    required this.authorId,
    required this.authorName,
    required this.likes,
    required this.likedBy,
    required this.createdAt,
  });

  factory RecipeModel.fromMap(Map<String, dynamic> map, String id) {
    return RecipeModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      cookingTime: map['cookingTime'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'cookingTime': cookingTime,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'likes': likes,
      'likedBy': likedBy,
      'createdAt': createdAt,
    };
  }

  RecipeModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? ingredients,
    String? cookingTime,
    String? imageUrl,
    String? authorId,
    String? authorName,
    int? likes,
    List<String>? likedBy,
    DateTime? createdAt,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      cookingTime: cookingTime ?? this.cookingTime,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 