import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui'; // For ImageFilter
import 'dart:convert';
import '../controllers/objects_controller.dart';
import '../models/restful_object.dart';
import '../routes/app_pages.dart';
import '../theme/app_theme.dart';

class DetailView extends GetView<ObjectsController> {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final String id = Get.arguments as String;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Object Details'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: AppColors.background.withOpacity(0.5)),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
            onPressed: () {
              // Pass the current object to edit view
              final obj = controller.objects.firstWhereOrNull((e) => e.id == id);
              if (obj != null) {
                Get.toNamed(Routes.EDIT, arguments: obj);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppColors.error),
            onPressed: () {
              Get.defaultDialog(
                title: 'Delete Object',
                titleStyle: const TextStyle(color: Colors.white),
                middleText: 'Are you sure you want to delete this object?',
                middleTextStyle: const TextStyle(color: AppColors.textSecondary),
                backgroundColor: AppColors.surface,
                textConfirm: 'Delete',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                buttonColor: AppColors.error,
                cancelTextColor: AppColors.textSecondary,
                onConfirm: () {
                  Get.back(); // Close dialog
                  controller.deleteObject(id);
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A), // Slate 900
                  Color(0xFF1E293B), // Slate 800
                  Color(0xFF0F172A), // Slate 900
                ],
              ),
            ),
          ),
          
          // 2. Background Abstract Shapes
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // 3. Content
          FutureBuilder<RestfulObject?>(
            future: controller.getObjectDetail(id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                 // If we have local data, show it while loading fresh
                 final localObj = controller.objects.firstWhereOrNull((e) => e.id == id);
                 if (localObj != null) {
                   return _buildContent(localObj);
                 }
                 return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError || snapshot.data == null) {
                // Try to fallback to local data if API fails
                final localObj = controller.objects.firstWhereOrNull((e) => e.id == id);
                if (localObj != null) {
                   return _buildContent(localObj);
                }
                return Center(child: Text('Error loading details: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
              }

              return _buildContent(snapshot.data!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(RestfulObject obj) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String prettyData = 'No Data';
    if (obj.data != null) {
      try {
        prettyData = encoder.convert(obj.data);
      } catch (e) {
        prettyData = obj.data.toString();
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              'ID: ${obj.id}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontFamily: 'Courier',
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            obj.name,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          
          // Data Card
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.data_object_rounded, color: AppColors.secondary),
                        const SizedBox(width: 12),
                        Text(
                          'Object Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Text(
                        prettyData,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
