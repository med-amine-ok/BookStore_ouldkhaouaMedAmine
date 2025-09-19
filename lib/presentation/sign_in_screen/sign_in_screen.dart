import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../forgot_password_screen/forgot_password_screen.dart';
import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import '../onboarding_screen/onboarding_screen.dart';
import '../sign_up_screen/sign_up_screen.dart';
import './widgets/custom_text_field.dart';
import './widgets/loading_overlay.dart';
import '../../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false;



  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null && mounted) {
        // Navigate to home screen
        Navigator.pushNamedAndRemoveUntil(context, '/home-screen', (route) => false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Signed in successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first')),
      );
      return;
    }

    try {
      await _authService.resetPassword(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📧 Password reset email sent!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to send reset email: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundLight,
      appBar: _buildAppBar(),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Signing you in...',
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
        'Sign In',
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
          'Welcome Back 👋',
          style: GoogleFonts.inter(
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          'Sign in to continue your reading journey with BookStore',
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
            SizedBox(height: 3.h),
            _buildPasswordField(),
            SizedBox(height: 2.h),
            _buildOptionsRow(),
            SizedBox(height: 4.h),
            _buildSignInButton(),
            SizedBox(height: 3.h),
            _buildSignUpLink(),
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

  Widget _buildPasswordField() {
    return CustomTextField(
      label: 'Password',
      hintText: 'Enter your password',
      controller: _passwordController,
      isPassword: true,
      isRequired: true,
      validator: _validatePassword,
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildRememberMeCheckbox(), _buildForgotPasswordLink()],
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _rememberMe
                    ? AppTheme.CafeAccent
                    : AppTheme.borderSubtle,
                width: _rememberMe ? 2 : 1,
              ),
              color: _rememberMe ? AppTheme.CafeAccent : Colors.transparent,
            ),
            child: _rememberMe
                ? CustomIconWidget(
                    iconName: 'check',
                    color: AppTheme.cardSurfaceLight,
                    size: 14,
                  )
                : null,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          'Remember me',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return GestureDetector(
      onTap: _navigateToForgotPassword,
      child: Text(
        'Forgot Password?',
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppTheme.CafeAccent,
          decoration: TextDecoration.underline,
          decorationColor: AppTheme.CafeAccent,
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _canSignIn ? _signIn : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canSignIn
              ? AppTheme.CafeAccent
              : AppTheme.textMuted,
          foregroundColor: AppTheme.cardSurfaceLight,
          elevation: _canSignIn ? 2 : 0,
          shadowColor: AppTheme.shadowBase,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Sign In',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondary,
          ),
          children: [
            const TextSpan(text: "Don't have an account? "),
            WidgetSpan(
              child: GestureDetector(
                onTap: _navigateToSignUp,
                child: Text(
                  'Sign Up',
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

  void _navigateToOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password-screen');
  }

  bool get _canSignIn {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        !_isLoading;
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
        child: const Text('OK'),
      ),
    );
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
            _buildContinueButton(),
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
      'Welcome Back!',
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
      'You\'ve successfully signed in to your account. Continue exploring our amazing collection!',
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppTheme.textSecondary,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home-screen',
            (route) => false,
          );
        },
        child: const Text('Continue'),
      ),
    );
  }

  void _showErrorDialog(String error) {
    final userFriendlyMessage = _getUserFriendlyErrorMessage(error);

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
          'Sign In Failed',
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
    if (error.contains('Invalid email or password')) {
      return 'The email or password you entered is incorrect. Please try again.';
    } else if (error.contains('network')) {
      return 'Please check your internet connection and try again.';
    } else if (error.contains('account not found')) {
      return 'No account found with this email. Please check your email or sign up.';
    }
    return 'Something went wrong. Please try again later.';
  }
}