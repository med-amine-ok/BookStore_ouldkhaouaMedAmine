import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this import

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showRequirements;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showRequirements = true,
  });

  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength(password);
    final requirements = _getPasswordRequirements(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength indicator bar
        Container(
          height: 4.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.2,
            ),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: strength.progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: strength.color,
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),

        // Strength text
        Text(
          strength.label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: strength.color,
          ),
        ),

        if (showRequirements && password.isNotEmpty) ...[
          SizedBox(height: 2.h),
          // Requirements list
          ...requirements.map(
            (requirement) => Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: requirement.isMet ? 'check_circle' : 'cancel',
                    color: requirement.isMet
                        ? AppTheme.successGreen
                        : AppTheme.lightTheme.colorScheme.error,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      requirement.text,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: requirement.isMet
                            ? AppTheme.textSecondary
                            : AppTheme.lightTheme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength(
        progress: 0.0,
        label: '',
        color: Colors.transparent,
      );
    }

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    switch (score) {
      case 0:
      case 1:
        return PasswordStrength(
          progress: 0.2,
          label: 'Very Weak',
          color: AppTheme.lightTheme.colorScheme.error,
        );
      case 2:
      case 3:
        return PasswordStrength(
          progress: 0.4,
          label: 'Weak',
          color: Colors.orange,
        );
      case 4:
        return PasswordStrength(
          progress: 0.6,
          label: 'Fair',
          color: Colors.amber,
        );
      case 5:
        return PasswordStrength(
          progress: 0.8,
          label: 'Good',
          color: AppTheme.CafeAccent,
        );
      case 6:
        return PasswordStrength(
          progress: 1.0,
          label: 'Strong',
          color: AppTheme.successGreen,
        );
      default:
        return PasswordStrength(
          progress: 0.0,
          label: '',
          color: Colors.transparent,
        );
    }
  }

  List<PasswordRequirement> _getPasswordRequirements(String password) {
    return [
      PasswordRequirement(
        text: 'At least 8 characters',
        isMet: password.length >= 8,
      ),
      PasswordRequirement(
        text: 'Contains lowercase letter',
        isMet: password.contains(RegExp(r'[a-z]')),
      ),
      PasswordRequirement(
        text: 'Contains uppercase letter',
        isMet: password.contains(RegExp(r'[A-Z]')),
      ),
      PasswordRequirement(
        text: 'Contains number',
        isMet: password.contains(RegExp(r'[0-9]')),
      ),
      PasswordRequirement(
        text: 'Contains special character',
        isMet: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      ),
    ];
  }
}

class PasswordStrength {
  final double progress;
  final String label;
  final Color color;

  PasswordStrength({
    required this.progress,
    required this.label,
    required this.color,
  });
}

class PasswordRequirement {
  final String text;
  final bool isMet;

  PasswordRequirement({required this.text, required this.isMet});
}
