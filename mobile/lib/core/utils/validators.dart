import 'package:flutter/material.dart';

class Validators {
  /// Validate phone number (Kenya format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and special characters
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Validate Kenyan phone format: +254XXXXXXXXX or 07XXXXXXXX
    final kenyaPhoneRegex = RegExp(r'^(\+254|0)?[7][0-9]{8}$');
    
    if (!kenyaPhoneRegex.hasMatch(cleanPhone)) {
      return 'Please enter a valid Kenyan phone number';
    }
    
    return null;
  }
  
  /// Validate OTP code
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP code is required';
    }
    
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    
    return null;
  }
  
  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    
    return null;
  }
  
  /// Validate description
  static String? validateDescription(String? value, {int maxLength = 1000}) {
    if (value != null && value.length > maxLength) {
      return 'Description must not exceed $maxLength characters';
    }
    
    return null;
  }
  
  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  /// Validate circle name
  static String? validateCircleName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Circle name is required';
    }
    
    if (value.length < 3) {
      return 'Circle name must be at least 3 characters';
    }
    
    if (value.length > 50) {
      return 'Circle name must not exceed 50 characters';
    }
    
    return null;
  }
  
  /// Validate contact phone
  static String? validateContactPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contact phone is required';
    }
    
    return validatePhone(value);
  }
  
  /// Validate contact name
  static String? validateContactName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contact name is required';
    }
    
    return validateName(value);
  }
}
