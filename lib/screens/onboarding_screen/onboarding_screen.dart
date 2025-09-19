import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../sign_in_screen/sign_in_screen.dart';
import '../sign_up_screen/sign_up_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const String _onboardingImagePath = "assets/images/onboard.png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            children: [
              SizedBox(height: 6.h),
              _buildIllustrationSection(),
              _buildContentSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustrationSection() {
    return Expanded(
      flex: 5,
      child: SizedBox(
        width: double.infinity,
        child: Image.asset(
          _onboardingImagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Expanded(
      flex: 3,
      child: Column(
        children: [
          _buildTitleText(),
          SizedBox(height: 2.h),
          _buildSubtitleText(),
          SizedBox(height: 4.h),
          _buildActionButtons(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildTitleText() {
    return Text(
      "Now reading books\nwill be easier",
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        color: AppTheme.textPrimary,
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
    );
  }

  Widget _buildSubtitleText() {
    return Text(
      "Discover new worlds join a vibrant\nreading community. Start your reading\nadventure effortlessly with us.",
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        color: AppTheme.textSecondary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Builder(
      builder: (context) => Row(
        children: [
          _buildContinueButton(context),
          SizedBox(width: 4.w),
          _buildSignInButton(context),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Expanded(
      flex: 2,
      child: SizedBox(
        height: 6.h,
        child: ElevatedButton(
          onPressed: () => _navigateToSignUp(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: AppTheme.primaryBackgroundLight,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            "Continue",
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return Expanded(
      flex: 1,
      child: SizedBox(
        height: 6.h,
        child: OutlinedButton(
          onPressed: () => _navigateToSignIn(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: BorderSide(
              color: AppTheme.primaryColor,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            "Sign In",
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSignUp(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  void _navigateToSignIn(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }
}