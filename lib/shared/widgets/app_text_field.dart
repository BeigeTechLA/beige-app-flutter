import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
  });

  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _internalFocusNode;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
    _effectiveFocusNode.addListener(_onFocusChange);
    widget.controller?.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode).removeListener(_onFocusChange);
      _effectiveFocusNode.addListener(_onFocusChange);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChange);
      widget.controller?.addListener(_onTextChange);
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
    widget.controller?.removeListener(_onTextChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() => setState(() {});
  void _onTextChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _effectiveFocusNode.hasFocus;
    final bool hasText = widget.controller?.text.isNotEmpty ?? false;
    final bool highlight = isFocused || hasText;

    return TextFormField(
      controller: widget.controller,
      focusNode: _effectiveFocusNode,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      cursorColor: AppColors.primary,
      enableSuggestions: !widget.obscureText,
      autocorrect: !widget.obscureText,
      style: const TextStyle(
        color: AppColors.white,
        fontFamily: AppTextStyles.fontFamilyBody,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffix,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(
          fontSize: 14,
          color: highlight ? AppColors.primary : AppColors.white60,
          fontFamily: AppTextStyles.fontFamilyBody,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: BorderSide(
            color: highlight ? AppColors.borderGold : AppColors.white30,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.lgAll,
          borderSide: const BorderSide(
            color: AppColors.borderGold,
            width: 0.5,
          ),
        ),
      ),
    );
  }
}