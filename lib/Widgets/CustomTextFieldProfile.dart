import 'package:flutter/material.dart';

class CustomTextFieldProfile extends StatefulWidget {
  final TextEditingController textEditingController;
  final String texts;
  final Icon icons_provided;
  const CustomTextFieldProfile({
    super.key,
    required this.textEditingController,
    required this.texts,
    required this.icons_provided,
  });

  @override
  State<CustomTextFieldProfile> createState() => _CustomTextFieldProfileState();
}

class _CustomTextFieldProfileState extends State<CustomTextFieldProfile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
      child: TextField(
        controller: widget.textEditingController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: widget.icons_provided,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(Icons.edit),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          hintText: widget.texts,
          filled: true,
          fillColor: Theme.of(context).colorScheme.inversePrimary,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
      ),
    );
  }
}
