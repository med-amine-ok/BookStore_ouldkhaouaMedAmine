import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../sign_in_screen/sign_in_screen.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/loading_overlay.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return _ForgotPasswordScreenContent(
      authState: authState,
      authNotifier: authNotifier,
    );
  }
}

class _ForgotPasswordScreenContent extends StatefulWidget {
  final AuthState authState;
  final AuthNotifier authNotifier;

  const _ForgotPasswordScreenContent({
    required this.authState,
    required this.authNotifier,
  });

  @override
  State<_ForgotPasswordScreenContent> createState() =>
      _ForgotPasswordScreenContentState();
}

class _ForgotPasswordScreenContentState
    extends State<_ForgotPasswordScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showErrorIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant _ForgotPasswordScreenContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authState.isLoading && !widget.authState.isLoading) {
      if (widget.authState.isPasswordResetSent && mounted) {
        _showPasswordResetSentDialog();
        widget.authNotifier.clearPasswordResetSent();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showErrorIfNeeded() {
    if (widget.authState.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Failed to send reset email: ${widget.authState.errorMessage}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      widget.authNotifier.clearError();
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    await widget.authNotifier.resetPassword(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundLight,
      appBar: _buildAppBar(),
      body: LoadingOverlay(
        isLoading: widget.authState.isLoading,
        message: 'Sending reset email...',
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
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Forgot Password',
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
          'Reset Your Password 🔑',
          style: GoogleFonts.inter(
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          'Enter your email address and we\'ll send you a link to reset your password',
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
            _buildEmailField(),
            SizedBox(height: 4.h),
            _buildSendButton(),
            SizedBox(height: 3.h),
            _buildBackToSignInLink(),
          ],
        ),
      ),
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

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _canSend ? _resetPassword : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canSend ? AppTheme.CafeAccent : AppTheme.textMuted,
          foregroundColor: AppTheme.cardSurfaceLight,
          elevation: _canSend ? 2 : 0,
          shadowColor: AppTheme.shadowBase,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Send Reset Link',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBackToSignInLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondary,
          ),
          children: [
            const TextSpan(text: "Remember your password? "),
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

  void _navigateToSignIn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  bool get _canSend {
    return _emailController.text.isNotEmpty && !widget.authState.isLoading;
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

  void _showPasswordResetSentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEmailSentIcon(),
            SizedBox(height: 3.h),
            _buildEmailSentTitle(),
            SizedBox(height: 1.h),
            _buildEmailSentMessage(),
            SizedBox(height: 3.h),
            _buildEmailSentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSentIcon() {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: AppTheme.CafeAccent.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: CustomIconWidget(
        iconName: 'email',
        color: AppTheme.CafeAccent,
        size: 48,
      ),
    );
  }

  Widget _buildEmailSentTitle() {
    return Text(
      'Check Your Email',
      style: GoogleFonts.inter(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailSentMessage() {
    return Text(
      'We\'ve sent a password reset link to your email address. Please check your inbox.',
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppTheme.textSecondary,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailSentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.CafeAccent,
          foregroundColor: AppTheme.cardSurfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'OK',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
