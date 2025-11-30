import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/app_pages.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Observables
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  
  // OTP Verification ID
  String? _verificationId;
  int? _resendToken;

  @override
  void onInit() {
    super.onInit();
    // Bind user stream to firebaseUser observable
    firebaseUser.bindStream(_auth.authStateChanges());
    // Redirect based on auth state
    ever(firebaseUser, _setInitialScreen);
    
    // Enable this for testing with fictional numbers on web
    _auth.setSettings(appVerificationDisabledForTesting: true);
  }

  void _setInitialScreen(User? user) {
    debugPrint('Auth State Changed: ${user?.uid}');
    if (user == null) {
      if (Get.currentRoute != Routes.LOGIN) {
        Get.offAllNamed(Routes.LOGIN);
      }
    } else {
      if (Get.currentRoute != Routes.HOME) {
        Get.offAllNamed(Routes.HOME);
      }
    }
  }

  // Web Confirmation Result
  ConfirmationResult? _webConfirmationResult;

  // 1. Send OTP
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    isLoading.value = true;
    try {
      if (GetPlatform.isWeb) {
        // Web specific implementation
        ConfirmationResult result = await _auth.signInWithPhoneNumber(phoneNumber);
        _webConfirmationResult = result; // Store it in the controller
        debugPrint('Phone verification started. Result obtained.');
        
        isLoading.value = false; // <--- FIX: Reset loading state before navigation
        Get.toNamed(Routes.OTP, arguments: {'phoneNumber': phoneNumber});
      } else {
        // Mobile implementation
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-retrieval or instant verification
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            isLoading.value = false;
            Get.snackbar(
              'Verification Failed',
              e.message ?? 'Unknown error',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red,
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            isLoading.value = false;
            _verificationId = verificationId;
            _resendToken = resendToken;
            Get.toNamed(Routes.OTP, arguments: {'phoneNumber': phoneNumber});
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to verify phone number: $e');
    }
  }

  // 2. Verify OTP
  Future<void> verifyOTP(String smsCode) async {
    isLoading.value = true;
    try {
      if (GetPlatform.isWeb) {
        if (_webConfirmationResult != null) {
          debugPrint('Confirming OTP: $smsCode');
          UserCredential userCredential = await _webConfirmationResult!.confirm(smsCode)
              .timeout(const Duration(seconds: 15), onTimeout: () {
                throw 'Verification timed out. Please try again.';
              });
          debugPrint('Web Login Success: ${userCredential.user?.uid}');
        } else {
          throw 'Confirmation result missing. Please try logging in again.';
        }
      } else {
        if (_verificationId == null) throw 'Verification ID missing';
        
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: smsCode,
        );
        await _auth.signInWithCredential(credential);
        debugPrint('Mobile Login Success');
      }
      // Manual navigation as backup
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      debugPrint('Error verifying OTP: $e'); // Added debug print
      Get.snackbar(
        'Invalid OTP',
        'Error: $e', // Show actual error
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      debugPrint('Verify OTP finished, loading false'); // Added debug print
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
