// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../models/recipe_model.dart';
// import '../providers/recipe_provider.dart';
// import '../providers/auth_provider.dart';
// import '../constants/colors.dart';
import 'package:flutter/material.dart';
import 'add_recipe_screen.dart';

// class RecipeDetailScreen extends StatefulWidget {
//   final RecipeModel recipe;

//   const RecipeDetailScreen({
//     super.key,
//     required this.recipe,
//   });

//   @override
//   State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
// }

// class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
//   bool _isLiked = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkIfLiked();
//   }

//   void _checkIfLiked() {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     if (authProvider.user != null) {
//       setState(() {
//         _isLiked = widget.recipe.likedBy.contains(authProvider.user!.uid);
//       });
//     }
//   }

//   Future<void> _toggleLike() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

//     if (authProvider.user != null) {
//       bool success = await recipeProvider.toggleLike(
//         widget.recipe.id,
//         authProvider.user!.uid,
//       );

//       if (success) {
//         setState(() {
//           _isLiked = !_isLiked;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           // App Bar with Image
//           SliverAppBar(
//             expandedHeight: 300,
//             pinned: true,
//             backgroundColor: AppColors.primary,
//             flexibleSpace: FlexibleSpaceBar(
//               background: CachedNetworkImage(
//                 imageUrl: widget.recipe.imageUrl,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Container(
//                   color: AppColors.grey300,
//                   child: const Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 ),
//                 errorWidget: (context, url, error) => Container(
//                   color: AppColors.grey300,
//                   child: Icon(
//                     Icons.restaurant,
//                     size: 100,
//                     color: AppColors.grey,
//                   ),
//                 ),
//               ),
//             ),
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back, color: AppColors.white),
//               onPressed: () => Navigator.pop(context),
//             ),
//             actions: [
//               Consumer<AuthProvider>(
//                 builder: (context, authProvider, child) {
//                   if (authProvider.user?.uid == widget.recipe.authorId) {
//                     return PopupMenuButton<String>(
//                       icon: const Icon(Icons.more_vert, color: AppColors.white),
//                       onSelected: (value) {
//                         if (value == 'edit') {
//                           // TODO: Navigate to edit screen
//                         } else if (value == 'delete') {
//                           _showDeleteDialog();
//                         }
//                       },
//                       itemBuilder: (context) => [
//                         const PopupMenuItem(
//                           value: 'edit',
//                           child: Row(
//                             children: [
//                               Icon(Icons.edit),
//                               SizedBox(width: 8),
//                               Text('Edit'),
//                             ],
//                           ),
//                         ),
//                         PopupMenuItem(
//                           value: 'delete',
//                           child: Row(
//                             children: [
//                               Icon(Icons.delete, color: AppColors.accent),
//                               SizedBox(width: 8),
//                               Text('Delete', style: TextStyle(color: AppColors.accent)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ],
//           ),

//           // Recipe Content
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Recipe Title and Author
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               widget.recipe.title,
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'by ${widget.recipe.authorName}',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: AppColors.grey600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Consumer<AuthProvider>(
//                         builder: (context, authProvider, child) {
//                           if (authProvider.user != null) {
//                             return IconButton(
//                               onPressed: _toggleLike,
//                               icon: Icon(
//                                 _isLiked ? Icons.favorite : Icons.favorite_border,
//                                 color: _isLiked ? AppColors.accent : AppColors.grey,
//                                 size: 28,
//                               ),
//                             );
//                           }
//                           return const SizedBox.shrink();
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),

//                   // Like Count
//                   Row(
//                     children: [
//                       Icon(Icons.favorite, color: AppColors.accentLight, size: 16),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${widget.recipe.likes} likes',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: AppColors.grey600,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // Cooking Time
//                   Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.access_time,
//                             color: AppColors.primary,
//                             size: 24,
//                           ),
//                           const SizedBox(width: 12),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Cooking Time',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: AppColors.grey,
//                                 ),
//                               ),
//                               Text(
//                                 widget.recipe.cookingTime,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Ingredients Section
//                   const Text(
//                     'Ingredients',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: widget.recipe.ingredients.map((ingredient) {
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 8,
//                                   height: 8,
//                                   decoration: BoxDecoration(
//                                     color: AppColors.primary,
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Text(
//                                     ingredient,
//                                     style: const TextStyle(fontSize: 16),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Instructions Section
//                   const Text(
//                     'Instructions',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Text(
//                         widget.recipe.description,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           height: 1.5,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Created Date
//                   Text(
//                     'Created on ${_formatDate(widget.recipe.createdAt)}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: AppColors.grey600,
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   void _showDeleteDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Recipe'),
//         content: const Text('Are you sure you want to delete this recipe?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
//               bool success = await recipeProvider.deleteRecipe(widget.recipe.id);
              
//               if (success && mounted) {
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                   content: const Text('Recipe deleted successfully!'),
//                   backgroundColor: AppColors.secondary,
//                 ),
//                 );
//               }
//             },
//             child: Text(
//               'Delete',
//               style: TextStyle(color: AppColors.accent),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// } 