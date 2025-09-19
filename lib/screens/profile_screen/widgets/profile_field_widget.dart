import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileFieldWidget extends StatefulWidget {
  final String label;
  final String value;
  final bool isEditable;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final VoidCallback? onEditTap;
  final bool isRequired;

  const ProfileFieldWidget({
    super.key,
    required this.label,
    required this.value,
    this.isEditable = true,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onEditTap,
    this.isRequired = false,
  });

  @override
  State<ProfileFieldWidget> createState() => _ProfileFieldWidgetState();
}

class _ProfileFieldWidgetState extends State<ProfileFieldWidget> {
  late TextEditingController _controller;
  bool _isEditing = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (widget.onEditTap != null) {
      widget.onEditTap!();
      return;
    }

    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Validate when stopping edit
        if (widget.validator != null) {
          _errorText = widget.validator!(_controller.text);
        }
        if (_errorText == null && widget.onChanged != null) {
          widget.onChanged!(_controller.text);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (widget.isRequired)
                Text(
                  '*',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
              if (widget.isEditable)
                GestureDetector(
                  onTap: _toggleEdit,
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    child: CustomIconWidget(
                      iconName: _isEditing ? 'check' : 'edit',
                      size: 4.w,
                      color: _isEditing
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: _errorText != null
                    ? AppTheme.lightTheme.colorScheme.error
                    : _isEditing
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline,
                width: _isEditing ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _controller,
              enabled: _isEditing,
              keyboardType: widget.keyboardType,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: _isEditing
                    ? AppTheme.lightTheme.colorScheme.onSurface
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                hintText:
                    _isEditing ? 'Enter ${widget.label.toLowerCase()}' : null,
                hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.6),
                ),
              ),
              onChanged: (value) {
                if (widget.validator != null) {
                  setState(() {
                    _errorText = widget.validator!(value);
                  });
                }
              },
            ),
          ),
          if (_errorText != null) ...[
            SizedBox(height: 0.5.h),
            Text(
              _errorText!,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
