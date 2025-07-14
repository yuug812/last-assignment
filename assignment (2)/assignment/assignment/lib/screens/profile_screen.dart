// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../providers/auth_provider.dart';
// import '../providers/recipe_provider.dart';
// import '../models/recipe_model.dart';
// import '../constants/colors.dart';
// import 'recipe_detail_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   bool _isEditing = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       if (authProvider.userData != null) {
//         _nameController.text = authProvider.userData!.name;
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   Future<void> _updateProfile() async {
//     if (_nameController.text.trim().isNotEmpty) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       bool success = await authProvider.updateProfile(
//         name: _nameController.text.trim(),
//       );

//       if (success && mounted) {
//         setState(() {
//           _isEditing = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Profile updated successfully!'),
//             backgroundColor: AppColors.secondary,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.white,
//         elevation: 0,
//         actions: [
//           Consumer<AuthProvider>(
//             builder: (context, authProvider, child) {
//               return IconButton(
//                 icon: const Icon(Icons.logout),
//                 onPressed: () async {
//                   await authProvider.signOut();
//                   if (mounted) {
//                     Navigator.of(context).popUntil((route) => route.isFirst);
//                   }
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Consumer<AuthProvider>(
//         builder: (context, authProvider, child) {
//           if (authProvider.userData == null) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Profile Header
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [AppColors.primary, AppColors.primaryLight],
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       children: [
//                         // Profile Avatar
//                         CircleAvatar(
//                           radius: 50,
//                           backgroundColor: AppColors.white,
//                           child: Text(
//                             authProvider.userData!.name.isNotEmpty
//                                 ? authProvider.userData!.name[0].toUpperCase()
//                                 : 'U',
//                             style: TextStyle(
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.primary,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         // User Name
//                         if (_isEditing)
//                           TextField(
//                             controller: _nameController,
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.white,
//                             ),
//                             textAlign: TextAlign.center,
//                             decoration: InputDecoration(
//                               border: InputBorder.none,
//                               hintText: 'Enter your name',
//                               hintStyle: TextStyle(color: AppColors.white70),
//                             ),
//                           )
//                         else
//                           Text(
//                             authProvider.userData!.name,
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.white,
//                             ),
//                           ),

//                         const SizedBox(height: 8),

//                         // Email
//                         Text(
//                           authProvider.userData!.email,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: AppColors.white70,
//                           ),
//                         ),

//                         const SizedBox(height: 16),

//                         // Edit Profile Button
//                         if (_isEditing)
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               ElevatedButton(
//                                 onPressed: _updateProfile,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.white,
//                                   foregroundColor: AppColors.primary,
//                                 ),
//                                 child: const Text('Save'),
//                               ),
//                               const SizedBox(width: 12),
//                               ElevatedButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     _isEditing = false;
//                                     _nameController.text = authProvider.userData!.name;
//                                   });
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.white24,
//                                   foregroundColor: AppColors.white,
//                                 ),
//                                 child: const Text('Cancel'),
//                               ),
//                             ],
//                           )
//                         else
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 _isEditing = true;
//                               });
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.white,
//                               foregroundColor: AppColors.primary,
//                             ),
//                             child: const Text('Edit Profile'),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // User Recipes
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'My Recipes',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       StreamBuilder<List<RecipeModel>>(
//                         stream: Provider.of<RecipeProvider>(context, listen: false)
//                             .getUserRecipesStream(authProvider.user!.uid),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return const Center(child: CircularProgressIndicator());
//                           }

//                           if (snapshot.hasError) {
//                             return Center(
//                               child: Text('Error: ${snapshot.error}'),
//                             );
//                           }

//                           List<RecipeModel> recipes = snapshot.data ?? [];

//                           if (recipes.isEmpty) {
//                             return const Center(
//                               child: Column(
//                                 children: [
//                                   Icon(
//                                     Icons.restaurant_menu,
//                                     size: 80,
//                                     color: Colors.grey,
//                                   ),
//                                   SizedBox(height: 16),
//                                   Text(
//                                     'No recipes yet',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     'Start sharing your favorite recipes!',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }

//                           return GridView.builder(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               crossAxisSpacing: 16,
//                               mainAxisSpacing: 16,
//                               childAspectRatio: 0.75,
//                             ),
//                             itemCount: recipes.length,
//                             itemBuilder: (context, index) {
//                               return _buildRecipeCard(recipes[index]);
//                             },
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildRecipeCard(RecipeModel recipe) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => RecipeDetailScreen(recipe: recipe),
//           ),
//         );
//       },
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Recipe Image
//             Expanded(
//               flex: 3,
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(12),
//                 ),
//                 child: CachedNetworkImage(
//                   imageUrl: recipe.imageUrl,
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   placeholder: (context, url) => Container(
//                     color: Colors.grey[300],
//                     child: const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                   ),
//                   errorWidget: (context, url, error) => Container(
//                     color: Colors.grey[300],
//                     child: const Icon(
//                       Icons.restaurant,
//                       size: 50,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // Recipe Info
//             Expanded(
//               flex: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       recipe.title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const Spacer(),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.access_time,
//                           size: 14,
//                           color: Colors.grey[600],
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           recipe.cookingTime,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const Spacer(),
//                         Icon(
//                           Icons.favorite,
//                           size: 14,
//                           color: Colors.red[400],
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${recipe.likes}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// } 