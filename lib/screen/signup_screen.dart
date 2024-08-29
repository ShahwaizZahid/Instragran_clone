import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/firebase_services/firebase_auth.dart';
import '../data/firebase_services/storage.dart';
import '../util/dialog.dart';
import '../util/exception.dart';
import '../util/imagepicker.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback show;
  SignupScreen(this.show, {super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  FocusNode email_F = FocusNode();
  final password = TextEditingController();
  FocusNode password_F = FocusNode();
  final passwordConfirme = TextEditingController();
  FocusNode passwordConfirme_F = FocusNode();
  final username = TextEditingController();
  FocusNode username_F = FocusNode();
  final bio = TextEditingController();
  FocusNode bio_F = FocusNode();
  File? _imageFile;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 100.h),
              Center(child: Image.asset('assets/images/logo.jpg')),
              SizedBox(height: 60.h),
              GestureDetector(
                onTap: () async {
                  File _imagefilee = await ImagePickerr().uploadImage('gallery');
                  setState(() {
                    _imageFile = _imagefilee;
                  });
                },
                child: CircleAvatar(
                  radius: 36.r,
                  backgroundColor: Colors.grey,
                  child: _imageFile == null
                      ? CircleAvatar(
                    radius: 34.r,
                    backgroundImage: AssetImage('assets/images/person.png'),
                    backgroundColor: Colors.grey.shade200,
                  )
                      : CircleAvatar(
                    radius: 34.r,
                    backgroundImage: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ).image,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              SizedBox(height: 50.h),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Textfild(email, email_F, 'Email', Icons.email, validateEmail),
                    SizedBox(height: 15.h),
                    Textfild(username, username_F, 'Username', Icons.person, validateUsername),
                    SizedBox(height: 15.h),
                    Textfild(bio, bio_F, 'Bio', Icons.abc, validateBio),
                    SizedBox(height: 15.h),
                    Textfild(password, password_F, 'Password', Icons.lock, validatePassword),
                    SizedBox(height: 15.h),
                    Textfild(passwordConfirme, passwordConfirme_F, 'Confirm Password', Icons.lock, validateConfirmPassword),
                    SizedBox(height: 20.h),
                    _isLoading
                        ? CircularProgressIndicator()
                        : SignupButton(),
                    SizedBox(height: 10.h),
                    HaveAccount(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget Textfild(TextEditingController controll, FocusNode focusNode, String typename, IconData icon, String? Function(String?)? validator) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: TextFormField(
        style: TextStyle(fontSize: 18.sp, color: Colors.black),
        controller: controll,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: typename,
          prefixIcon: Icon(
            icon,
            color: focusNode.hasFocus ? Colors.black : Colors.grey[600],
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.r),
            borderSide: BorderSide(
              width: 2.w,
              color: Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.r),
            borderSide: BorderSide(
              width: 2.w,
              color: Colors.black,
            ),
          ),
        ),
        validator: validator,
        obscureText: typename.toLowerCase().contains('password'),
      ),
    );
  }

  Widget SignupButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: InkWell(
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            setState(() {
              _isLoading = true;
            });

            try {
              await Authentication().Signup(
                email: email.text,
                password: password.text,
                passwordConfirme: passwordConfirme.text,
                username: username.text,
                bio: bio.text,
                profile: _imageFile ?? File(''),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Signup successful!'),
                  backgroundColor: Colors.green, // Customize the background color here
                  duration: Duration(seconds: 3),
                ),
              );

              // Optionally navigate to another screen or clear the form
              // Navigator.pushReplacementNamed(context, '/login');
            } on exceptions catch (e) {
              dialogBuilder(context, e.message);
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 44.h,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            'Signup',
            style: TextStyle(
              fontSize: 23.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget HaveAccount() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Don't have an account?  ",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          GestureDetector(
            onTap: widget.show,
            child: Text(
              "Login ",
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Add more validation rules if needed
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    // Add more validation rules if needed
    return null;
  }

  String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your bio';
    }
    // Add more validation rules if needed
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    // Add more validation rules if needed
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
