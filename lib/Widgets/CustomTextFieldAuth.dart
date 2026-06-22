import 'package:flutter/material.dart';

class CustomTextFieldAuth extends StatefulWidget {
  final TextEditingController textEditingController;
  final String texts;
  final bool hideText;

  const CustomTextFieldAuth({
    super.key,
    required this.textEditingController,
    required this.texts,
    required this.hideText,
  });

  @override
  State<CustomTextFieldAuth> createState() => _CustomTextFieldAuthState();
}

class _CustomTextFieldAuthState extends State<CustomTextFieldAuth> {
  late bool _isObscured;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isObscured = widget.hideText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
      child: TextField(
        controller: widget.textEditingController,
        obscureText: _isObscured,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                if (_isObscured) {
                  _isObscured = false;
                } else {
                  _isObscured = true;
                }
              });
            },
            icon: _isObscured
                ? Icon(Icons.visibility_off)
                : Icon(Icons.visibility),
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
