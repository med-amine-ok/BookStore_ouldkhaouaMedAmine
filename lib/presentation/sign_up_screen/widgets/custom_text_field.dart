import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool isRequired;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final bool enabled;
  final int maxLines;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.isRequired = false,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _hasFocus = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _validateField() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(widget.controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool hasError = _errorText != null && _errorText!.isNotEmpty;
    final bool hasValue = widget.controller.text.isNotEmpty;
    final bool isValid = hasValue && !hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        RichText(
          text: TextSpan(
            text: widget.label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            children: widget.isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: GoogleFonts.inter(color: colorScheme.error),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 1.h),

        // Text Field
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _hasFocus = hasFocus;
            });
            if (!hasFocus) {
              _validateField();
            }
          },
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword ? _obscureText : false,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: widget.enabled ? AppTheme.textPrimary : AppTheme.textMuted,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.textMuted,
              ),
              filled: true,
              fillColor: widget.enabled
                  ? AppTheme.cardSurfaceLight
                  : AppTheme.cardSurfaceLight.withValues(alpha: 0.5),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppTheme.borderSubtle, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isValid
                      ? AppTheme.successGreen
                      : AppTheme.borderSubtle,
                  width: isValid ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: hasError ? colorScheme.error : AppTheme.CafeAccent,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.error, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.error, width: 2),
              ),
              suffixIcon: _buildSuffixIcon(isValid, hasError),
            ),
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
              // Clear error when user starts typing
              if (hasError) {
                setState(() {
                  _errorText = null;
                });
              }
            },
            validator: widget.validator,
          ),
        ),

        // Error text
        if (hasError) ...[
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: colorScheme.error,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  _errorText!,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon(bool isValid, bool hasError) {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    if (widget.isPassword) {
      return IconButton(
        icon: CustomIconWidget(
          iconName: _obscureText ? 'visibility' : 'visibility_off',
          color: AppTheme.textMuted,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.controller.text.isNotEmpty) {
      if (isValid) {
        return Padding(
          padding: EdgeInsets.only(right: 3.w),
          child: CustomIconWidget(
            iconName: 'check_circle',
            color: AppTheme.successGreen,
            size: 20,
          ),
        );
      } else if (hasError) {
        return Padding(
          padding: EdgeInsets.only(right: 3.w),
          child: CustomIconWidget(
            iconName: 'error',
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
        );
      }
    }

    return null;
  }
}
