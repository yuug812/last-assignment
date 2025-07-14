import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/recipe_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';
import '../models/recipe_model.dart';

class AddRecipeScreen extends StatefulWidget {
  final RecipeModel? recipe;
  const AddRecipeScreen({super.key, this.recipe});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [
    TextEditingController(),
  ];
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _titleController.text = widget.recipe!.title;
      _descriptionController.text = widget.recipe!.description;
      _cookingTimeController.text = widget.recipe!.cookingTime;
      _ingredientControllers.clear();
      for (var ingredient in widget.recipe!.ingredients) {
        _ingredientControllers.add(TextEditingController(text: ingredient));
      }
      // الصورة: لا يمكن تعبئتها مباشرة من URL، نتركها فارغة حتى يختار المستخدم صورة جديدة إذا أراد
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cookingTimeController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  Future<void> _submitRecipe() async {
    if (_formKey.currentState!.validate() && (_selectedImage != null || widget.recipe != null)) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      List<String> ingredients = _ingredientControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      bool success;
      if (widget.recipe != null) {
        // تعديل وصفة
        success = await recipeProvider.updateRecipe(
          recipeId: widget.recipe!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          ingredients: ingredients,
          cookingTime: _cookingTimeController.text.trim(),
          imageFile: _selectedImage, // فقط إذا اختار صورة جديدة
        );
      } else {
        // إضافة وصفة جديدة
        success = await recipeProvider.addRecipe(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          ingredients: ingredients,
          cookingTime: _cookingTimeController.text.trim(),
          imageFile: _selectedImage!,
          authorId: authProvider.user!.uid,
          authorName: authProvider.user?.displayName ?? authProvider.user?.email ?? 'Unknown',
        );
      }
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.recipe != null ? 'Recipe updated successfully!' : 'Recipe added successfully!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.recipe != null ? 'Failed to update recipe. Please try again.' : 'Failed to add recipe. Please try again.'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } else if (_selectedImage == null && widget.recipe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an image for your recipe.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe != null ? 'Edit Recipe' : 'Add Recipe'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Selection
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.grey100,
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 60,
                              color: AppColors.grey400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add Recipe Photo',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Image Picker Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Select Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recipe Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Recipe Title',
                  prefixIcon: const Icon(Icons.restaurant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.grey50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a recipe title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cooking Time
              TextFormField(
                controller: _cookingTimeController,
                decoration: InputDecoration(
                  labelText: 'Cooking Time (e.g., 30 minutes)',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.grey50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cooking time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description/Instructions',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.grey50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter recipe description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Ingredients Section
              Row(
                children: [
                  Icon(Icons.list, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _addIngredientField,
                    icon: Icon(Icons.add_circle, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Ingredients List
              ...List.generate(_ingredientControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ingredientControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Ingredient ${index + 1}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.grey50,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter ingredient';
                            }
                            return null;
                          },
                        ),
                      ),
                      if (_ingredientControllers.length > 1)
                        IconButton(
                          onPressed: () => _removeIngredientField(index),
                          icon: Icon(Icons.remove_circle, color: AppColors.accent),
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 32),

              // Submit Button
              Consumer<RecipeProvider>(
                builder: (context, recipeProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: recipeProvider.isLoading ? null : _submitRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: recipeProvider.isLoading
                          ? CircularProgressIndicator(color: AppColors.white)
                          : Text(
                              widget.recipe != null ? 'Update Recipe' : 'Add Recipe',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 