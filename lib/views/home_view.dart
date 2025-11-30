import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui'; // For ImageFilter
import '../controllers/auth_controller.dart';
import '../controllers/objects_controller.dart';
import '../routes/app_pages.dart';
import '../theme/app_theme.dart';

class HomeView extends GetView<ObjectsController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are initialized
    Get.put(ObjectsController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Objects List'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: AppColors.background.withOpacity(0.5)),
          ),
        ),
        actions: [
          _ReloadButton(controller: controller),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () {
              Get.defaultDialog(
                title: 'Logout',
                titleStyle: const TextStyle(color: Colors.white),
                middleText: 'Are you sure you want to logout?',
                middleTextStyle: const TextStyle(color: AppColors.textSecondary),
                backgroundColor: AppColors.surface,
                textConfirm: 'Logout',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                buttonColor: AppColors.error,
                cancelTextColor: AppColors.textSecondary,
                onConfirm: () {
                  Get.back(); // Close dialog
                  authController.signOut();
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
          
          // 2. Background Abstract Shapes (Subtle)
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // 3. Content
          Obx(() {
            if (controller.isLoading.value && controller.objects.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (controller.objects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'No objects found',
                      style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => Get.toNamed(Routes.CREATE),
                      icon: const Icon(Icons.add),
                      label: const Text('Create First Object'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchObjects,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 80), // Top padding for AppBar
                itemCount: controller.objects.length,
                itemBuilder: (context, index) {
                  final obj = controller.objects[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.surface.withOpacity(0.6),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Get.toNamed(Routes.DETAIL, arguments: obj.id),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Icon Container
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.devices_other_rounded, color: AppColors.primary),
                              ),
                              const SizedBox(width: 16),
                              
                              // Text Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      obj.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: ${obj.id}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontFamily: 'Courier',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Arrow
                              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.CREATE),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Object'),
      ),
    );
  }
}

class _ReloadButton extends StatefulWidget {
  final ObjectsController controller;
  const _ReloadButton({required this.controller});

  @override
  State<_ReloadButton> createState() => _ReloadButtonState();
}

class _ReloadButtonState extends State<_ReloadButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Listen to loading state
    ever(widget.controller.isLoading, (isLoading) {
      if (isLoading) {
        _animController.repeat();
      } else {
        _animController.stop();
        _animController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animController,
      child: IconButton(
        icon: const Icon(Icons.refresh_rounded, color: AppColors.secondary),
        onPressed: widget.controller.fetchObjects,
        tooltip: 'Reload Objects',
      ),
    );
  }
}
