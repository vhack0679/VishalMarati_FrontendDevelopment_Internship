import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui'; // For ImageFilter
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController otpController = TextEditingController();
    final String phoneNumber = Get.arguments?['phoneNumber'] ?? '';

    return Scaffold(
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
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // 3. Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface.withOpacity(0.5),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.mark_email_read_rounded, size: 60, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 40),

                  // Glassmorphism Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Verification',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter code sent to $phoneNumber',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            
                            // OTP Input
                            TextField(
                              controller: otpController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 24, letterSpacing: 8, color: Colors.white, fontWeight: FontWeight.bold),
                              maxLength: 6,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: '000000',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Verify Button
                            Obx(() => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (otpController.text.length == 6) {
                                          controller.verifyOTP(otpController.text);
                                        } else {
                                          Get.snackbar('Error', 'Please enter a 6-digit code');
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary, // Cyan for Verify
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text('Verify Code'),
                              ),
                            )),
                            
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                'Wrong number? Go back',
                                style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
