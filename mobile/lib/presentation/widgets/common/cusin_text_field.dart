import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Custom text field widget
class CUSINTextField extends ConsumerStatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  
  const CUSINTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });
  
  @override
  ConsumerState<CUSINTextField> createState() => _CUSINTextFieldState();
}

class _CUSINTextFieldState extends ConsumerState<CUSINTextField> {
  late bool _obscureText;
  
  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.initialValue : null,
      obscureText: _obscureText,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      textCapitalization: widget.textCapitalization,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.suffixIcon != null
            ? IconButton(
                icon: Icon(
                  widget.obscureText
                      ? (widget.suffixIcon ?? Icons.visibility_off)
                      : (widget.suffixIcon ?? Icons.visibility),
                ),
                onPressed: widget.obscureText
                    ? () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      }
                    : widget.onSuffixIconTap,
              )
            : null,
      ),
    );
  }
}
