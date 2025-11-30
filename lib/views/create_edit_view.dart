import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui'; // For ImageFilter
import 'dart:convert';
import '../controllers/objects_controller.dart';
import '../models/restful_object.dart';
import '../utils/json_validator.dart';
import '../theme/app_theme.dart';

class CreateEditView extends GetView<ObjectsController> {
  const CreateEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final RestfulObject? existingObj = Get.arguments as RestfulObject?;
    final isEditing = existingObj != null;

    final TextEditingController nameController = TextEditingController(text: existingObj?.name ?? '');
    final TextEditingController dataController = TextEditingController(
      text: existingObj?.data != null 
          ? const JsonEncoder.withIndent('  ').convert(existingObj!.data) 
          : '{\n  "year": 2023,\n  "price": 1849.99,\n  "CPU model": "Intel Core i9",\n  "Hard disk size": "1 TB"\n}',
    );
    
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Object' : 'Create Object'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: AppColors.background.withOpacity(0.5)),
          ),
        ),
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
            top: 100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isEditing ? 'Update Details' : 'New Entry',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          
                          // Name Input
                          TextFormField(
                            controller: nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Object Name',
                              hintText: 'e.g. Apple MacBook Pro 16',
                              prefixIcon: Icon(Icons.label_outline_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Data Input
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4, bottom: 8),
                                child: Text('Data (JSON Format)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                              ),
                              TextFormField(
                                controller: dataController,
                                maxLines: 10,
                                style: const TextStyle(fontFamily: 'Courier', color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: '{\n  "key": "value"\n}',
                                  alignLabelWithHint: true,
                                  fillColor: Colors.black.withOpacity(0.2),
                                ),
                                validator: JsonValidator.validate,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Submit Button
                          Obx(() => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: controller.isSaving.value
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        final name = nameController.text.trim();
                                        final data = JsonValidator.tryParse(dataController.text)!;
                                        
                                        bool success;
                                        if (isEditing) {
                                          success = await controller.updateObject(existingObj!.id, name, data);
                                        } else {
                                          success = await controller.createObject(name, data);
                                        }

                                        if (success) {
                                          Get.back();
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: AppColors.primary,
                              ),
                              child: controller.isSaving.value
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(isEditing ? Icons.save_rounded : Icons.add_circle_outline_rounded),
                                        const SizedBox(width: 8),
                                        Text(isEditing ? 'Update Object' : 'Create Object'),
                                      ],
                                    ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
