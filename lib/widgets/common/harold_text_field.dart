import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomHaroldTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final Iterable<String>? autoFillHints;
  final int? maxLines;
  final String? hintText;
  final TextInputType? inputType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String? val)? validator;

  const CustomHaroldTextField(
      {required this.label,
      this.controller,
      this.autoFillHints,
      this.maxLines,
      this.validator,
      this.inputFormatters,
      this.inputType,
      this.hintText,
      Key? key})
      : super(key: key);

  OutlineInputBorder get border => OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
      );

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
            color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w400),
      ),
      const SizedBox(
        height: 6,
      ),
      TextFormField(
        controller: controller,
        autofillHints: autoFillHints,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: Colors.black, fontSize: 14),
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
            enabledBorder: border,
            errorStyle:
                const TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
            focusedBorder: border,
            border: border),
      )
    ]);
  }
}
