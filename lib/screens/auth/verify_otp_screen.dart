import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/providers/auth_state_provider.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';
import 'package:schmgtsystem/home3.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class VerifyOTPScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyOTPScreen({Key? key, required this.email}) : super(key: key);

  @override
  ConsumerState<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends ConsumerState<VerifyOTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isVerifyingOTP = false;
  bool _otpVerified = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int? _otpExpiresIn;
  int? _attemptsRemaining;

  // Resend OTP cooldown
  int _resendCooldown = 120; // 2 minutes in seconds
  bool _canResendOTP = false;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _checkOTPStatus();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkOTPStatus() async {
    try {
      final authProvider = ref.read(RiverpodProvider.authProvider);
      final status = await authProvider.getOTPStatus(widget.email);

      if (status != null && status.hasOTP) {
        setState(() {
          _otpExpiresIn = status.expiresIn;
          _attemptsRemaining = status.attemptsRemaining;
        });
      } else {
        CustomToastNotification.show(
          'No active verification code found. Please request a new one.',
          type: ToastType.error,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      CustomToastNotification.show(
        'Error checking OTP status: $e',
        type: ToastType.error,
      );
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().isEmpty) {
      CustomToastNotification.show(
        'Please enter the verification code',
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _isVerifyingOTP = true;
    });

    try {
      final authProvider = ref.read(RiverpodProvider.authProvider);
      final response = await authProvider.verifyOTP(
        email: widget.email,
        otp: _otpController.text.trim(),
      );

      if (response != null && response.success) {
        setState(() {
          _otpVerified = true;
          _otpExpiresIn = response.expiresAt;
          _attemptsRemaining = response.attemptsRemaining;
        });
        CustomToastNotification.show(
          'OTP verified successfully! You can now set your new password.',
          type: ToastType.success,
        );
      } else {
        setState(() {
          _attemptsRemaining = response?.attemptsRemaining;
        });
        // Refresh OTP status to get the latest attempts remaining
        await _checkOTPStatus();
      }
    } catch (e) {
      CustomToastNotification.show(
        'Error verifying OTP: $e',
        type: ToastType.error,
      );
    } finally {
      setState(() {
        _isVerifyingOTP = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_otpVerified) {
      CustomToastNotification.show(
        'Please verify the OTP first',
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = ref.read(RiverpodProvider.authProvider);
      final response = await authProvider.resetPasswordWithOTP(
        email: widget.email,
        otp: _otpController.text.trim(),
        newPassword: _passwordController.text.trim(),
      );

      print('Password reset response: $response');
      print('Response success: ${response?.success}');

      if (response != null && response.success) {
        CustomToastNotification.show(
          'Password reset successfully! You can now log in with your new password.',
          type: ToastType.success,
        );

        // Wait a moment for the toast to show, then navigate
        await Future.delayed(const Duration(seconds: 2));

        // Use GoRouter compatible navigation
        if (mounted) {
          print('Navigating to login using GoRouter...');
          // Clear authentication state to prevent redirect issues
          ref.read(authStateProvider.notifier).logout();

          // Use GoRouter's pushReplacement to replace current route
          context.pushReplacement('/login');
          print('Navigation completed');
        }
      }
    } catch (e) {
      CustomToastNotification.show(
        'Error resetting password: $e',
        type: ToastType.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTimeRemaining(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _startResendCooldown() {
    _canResendOTP = false;
    _resendCooldown = 120; // Reset to 2 minutes

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        setState(() {
          _canResendOTP = true;
        });
        timer.cancel();
      }
    });
  }

  void _resetResendCooldown() {
    _resendTimer?.cancel();
    _startResendCooldown();
  }

  Future<void> _resendOTP() async {
    try {
      EasyLoading.show(status: 'Resending OTP...');

      final authProvider = ref.read(RiverpodProvider.authProvider);
      final response = await authProvider.requestPasswordReset(widget.email);

      EasyLoading.dismiss();

      if (response != null && response.success) {
        CustomToastNotification.show(
          'New verification code sent to your email',
          type: ToastType.success,
        );
        _resetResendCooldown();

        // Refresh OTP status to get updated attempts remaining
        await _checkOTPStatus();
      } else {
        CustomToastNotification.show(
          'Failed to resend verification code',
          type: ToastType.error,
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error resending verification code: $e',
        type: ToastType.error,
      );
    }
  }

  String _formatResendCooldown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Verify Code',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // Header
                const Text(
                  'Enter Verification Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'We sent a 6-digit code to ${widget.email}',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 16,
                  ),
                ),

                if (_otpExpiresIn != null && _otpExpiresIn! > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Code expires in: ${_formatTimeRemaining(_otpExpiresIn!)}',
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                if (_attemptsRemaining != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Attempts remaining: $_attemptsRemaining',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // OTP Field
                const Text(
                  'Verification Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF374151)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF374151)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF6366F1),
                        width: 2,
                      ),
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the verification code';
                    }
                    if (value.length != 6) {
                      return 'Please enter a 6-digit code';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Verify OTP Button
                if (!_otpVerified) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isVerifyingOTP ? null : _verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isVerifyingOTP
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Verify Code',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],

                // Password Fields (shown after OTP verification)
                if (_otpVerified) ...[
                  const SizedBox(height: 32),

                  const Text(
                    'Set New Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // New Password Field
                  const Text(
                    'New Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter new password',
                      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF374151)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF374151)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF6B7280),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF6B7280),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Confirm Password Field
                  const Text(
                    'Confirm New Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Confirm new password',
                      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF374151)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF374151)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF6B7280),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF6B7280),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Reset Password Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Reset Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Manual Login Button (temporary)

                // Resend Code Countdown Display
                if (!_canResendOTP) ...[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF374151)),
                      ),
                      child: Text(
                        'Resend available in ${_formatResendCooldown(_resendCooldown)}',
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Resend Code Button
                Center(
                  child:
                      _canResendOTP
                          ? TextButton(
                            onPressed: _resendOTP,
                            child: const Text(
                              'Resend Code',
                              style: TextStyle(
                                color: Color(0xFF6366F1),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                          : TextButton(
                            onPressed: null, // Disabled during cooldown
                            child: Text(
                              'Resend Code',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
