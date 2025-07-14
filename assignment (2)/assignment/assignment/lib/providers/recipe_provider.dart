import 'dart:io';
import 'package:flutter/material.dart';
import '../services/recipe_service.dart';
import '../models/recipe_model.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  List<RecipeModel> _recipes = [];
  List<RecipeModel> _userRecipes = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<RecipeModel> get recipes => _recipes;
  List<RecipeModel> get userRecipes => _userRecipes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Get all recipes
  Stream<List<RecipeModel>> getRecipesStream() {
    return _recipeService.getRecipesStream();
  }

  // Get user recipes
  Stream<List<RecipeModel>> getUserRecipesStream(String userId) {
    return _recipeService.getUserRecipesStream(userId);
  }

  // Search recipes
  Stream<List<RecipeModel>> searchRecipes(String query) {
    _searchQuery = query;
    notifyListeners();
    return _recipeService.searchRecipes(query);
  }

  // Add recipe
  Future<bool> addRecipe({
    required String title,
    required String description,
    required List<String> ingredients,
    required String cookingTime,
    required File imageFile,
    required String authorId,
    required String authorName,
  }) async {
    _setLoading(true);
    try {
      String? recipeId = await _recipeService.addRecipe(
        title: title,
        description: description,
        ingredients: ingredients,
        cookingTime: cookingTime,
        imageFile: imageFile,
        authorId: authorId,
        authorName: authorName,
      );
      return recipeId != null;
    } catch (e) {
      print('Add recipe error: $e');
      return false;
    } finally {
      _setLoading(false);
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
    _setLoading(true);
    try {
      bool success = await _recipeService.updateRecipe(
        recipeId: recipeId,
        title: title,
        description: description,
        ingredients: ingredients,
        cookingTime: cookingTime,
        imageFile: imageFile,
      );
      return success;
    } catch (e) {
      print('Update recipe error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete recipe
  Future<bool> deleteRecipe(String recipeId) async {
    _setLoading(true);
    try {
      bool success = await _recipeService.deleteRecipe(recipeId);
      return success;
    } catch (e) {
      print('Delete recipe error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle like
  Future<bool> toggleLike(String recipeId, String userId) async {
    try {
      bool success = await _recipeService.toggleLike(recipeId, userId);
      return success;
    } catch (e) {
      print('Toggle like error: $e');
      return false;
    }
  }

  // Get single recipe
  Future<RecipeModel?> getRecipe(String recipeId) async {
    try {
      return await _recipeService.getRecipe(recipeId);
    } catch (e) {
      print('Get recipe error: $e');
      return null;
    }
  }

  // Update recipes list
  void updateRecipes(List<RecipeModel> recipes) {
    _recipes = recipes;
    notifyListeners();
  }

  // Update user recipes list
  void updateUserRecipes(List<RecipeModel> recipes) {
    _userRecipes = recipes;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 