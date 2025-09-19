import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import '../onboarding_screen/onboarding_screen.dart';
import '../sign_in_screen/sign_in_screen.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/loading_overlay.dart';
import 'widgets/password_strength_indicator.dart';
import 'widgets/terms_checkbox.dart';
import '../../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _acceptTerms = false;
  bool _showPasswordRequirements = false;
  String _currentPassword = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundLight,
      appBar: _buildAppBar(),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Creating your account...',
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryBackgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back_ios',
          color: AppTheme.textPrimary,
          size: 24,
        ),
        onPressed: _navigateToOnboarding,
      ),
      title: Text(
        'Create Account',
        style: GoogleFonts.inter(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            _buildWelcomeSection(),
            SizedBox(height: 4.h),
            _buildFormCard(),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Text(
          'Join BookStore',
          style: GoogleFonts.inter(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          'Discover your next favorite book and join our community of book lovers',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.cardSurfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowBase,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFullNameField(),
            SizedBox(height: 3.h),
            _buildEmailField(),
            SizedBox(height: 3.h),
            _buildPasswordField(),
            if (_showPasswordRequirements) ...[
              SizedBox(height: 2.h),
              PasswordStrengthIndicator(
                password: _currentPassword,
                showRequirements: true,
              ),
            ],
            SizedBox(height: 3.h),
            _buildConfirmPasswordField(),
            SizedBox(height: 4.h),
            _buildTermsCheckbox(),
            SizedBox(height: 4.h),
            _buildCreateAccountButton(),
            SizedBox(height: 3.h),
            _buildSignInLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildFullNameField() {
    return CustomTextField(
      label: 'Full Name',
      hintText: 'Enter your full name',
      controller: _fullNameController,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      validator: _validateFullName,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
      ],
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      label: 'Email Address',
      hintText: 'Enter your email address',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      isRequired: true,
      validator: _validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      label: 'Password',
      hintText: 'Create a strong password',
      controller: _passwordController,
      isPassword: true,
      isRequired: true,
      validator: _validatePassword,
      onChanged: _handlePasswordChange,
    );
  }

  Widget _buildConfirmPasswordField() {
    return CustomTextField(
      label: 'Confirm Password',
      hintText: 'Re-enter your password',
      controller: _confirmPasswordController,
      isPassword: true,
      isRequired: true,
      validator: _validateConfirmPassword,
    );
  }

  Widget _buildTermsCheckbox() {
    return TermsCheckbox(
      isChecked: _acceptTerms,
      onChanged: (value) => setState(() => _acceptTerms = value ?? false),
    );
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _canCreateAccount ? _handleSignUp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canCreateAccount
              ? AppTheme.CafeAccent
              : AppTheme.textMuted,
          foregroundColor: AppTheme.cardSurfaceLight,
          elevation: _canCreateAccount ? 2 : 0,
          shadowColor: AppTheme.shadowBase,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Create Account',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondary,
          ),
          children: [
            const TextSpan(text: 'Already have an account? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: _navigateToSignIn,
                child: Text(
                  'Sign In',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.CafeAccent,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.CafeAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePasswordChange(String value) {
    setState(() {
      _currentPassword = value;
      _showPasswordRequirements = value.isNotEmpty;
    });
  }

  void _navigateToOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  void _navigateToSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  bool get _canCreateAccount {
    return _acceptTerms &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        !_isLoading;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmedValue)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return 'Email address is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';

    final password = value!;
    final validations = [
      (password.length >= 8, 'Password must be at least 8 characters'),
      (
        password.contains(RegExp(r'[a-z]')),
        'Password must contain at least one lowercase letter',
      ),
      (
        password.contains(RegExp(r'[A-Z]')),
        'Password must contain at least one uppercase letter',
      ),
      (
        password.contains(RegExp(r'[0-9]')),
        'Password must contain at least one number',
      ),
      (
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
        'Password must contain at least one special character',
      ),
    ];

    for (final (isValid, message) in validations) {
      if (!isValid) return message;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      if (!mounted) return;

      // If email confirmation is enabled: user may be created without a session
      if (response.user != null && response.session == null) {
        _showErrorDialog(
          'Account created. Please verify your email, then sign in.',
        );
        return;
      }

      if (response.user != null) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) _showErrorDialog(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSuccessIcon(),
            SizedBox(height: 3.h),
            _buildSuccessTitle(),
            SizedBox(height: 1.h),
            _buildSuccessMessage(),
            SizedBox(height: 3.h),
            _buildGetStartedButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: CustomIconWidget(
        iconName: 'check_circle',
        color: AppTheme.successGreen,
        size: 48,
      ),
    );
  }

  Widget _buildSuccessTitle() {
    return Text(
      'Welcome to BookStore!',
      style: GoogleFonts.inter(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSuccessMessage() {
    return Text(
      'Your account has been created successfully. Start exploring our collection of amazing books!',
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppTheme.textSecondary,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        },
        child: const Text('Get Started'),
      ),
    );
  }

  void _showErrorDialog(Object error) {
    // Prefer showing Supabase auth message when available
    final message = error is AuthException ? error.message : error.toString();
    final userFriendlyMessage = _getUserFriendlyErrorMessage(message);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: _buildErrorTitle(),
        content: Text(
          userFriendlyMessage,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Try Again',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.CafeAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorTitle() {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'error_outline',
          color: Theme.of(context).colorScheme.error,
          size: 24,
        ),
        SizedBox(width: 2.w),
        Text(
          'Sign Up Failed',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  String _getUserFriendlyErrorMessage(String error) {
    final lower = error.toLowerCase();
    if (lower.contains('email already exists')) {
      return 'An account with this email already exists. Please try signing in instead.';
    } else if (lower.contains('network')) {
      return 'Please check your internet connection and try again.';
    } else if (lower.contains('weak password')) {
      return 'Please choose a stronger password with at least 8 characters.';
    } else if (lower.contains('provider') && lower.contains('disabled')) {
      return 'Email sign-ups are disabled. Please enable the Email provider in Supabase (Auth → Providers) and try again.';
    }
    return 'Something went wrong. Please try again later.';
  }
}