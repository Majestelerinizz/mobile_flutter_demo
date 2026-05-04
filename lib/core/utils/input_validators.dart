import 'package:flutter/material.dart';

/// Input validation utilities for AidatPanel forms
/// Provides comprehensive validation with Turkish error messages
class InputValidators {
  // Regex patterns
  static final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final phoneRegex = RegExp(r'^[0-9]{10}$');

  static final nameRegex = RegExp(r'^[a-zA-ZçğıöşüÇĞİÖŞÜ\s]{2,50}$');

  static final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  /// Email validation with Turkish error messages
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email adresi boş bırakılamaz';
    }

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir email adresi giriniz';
    }

    if (value.length > 100) {
      return 'Email adresi çok uzun';
    }

    return null;
  }

  /// Phone number validation (10 digits without country code)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası boş bırakılamaz';
    }

    final cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Telefon numarası 10 haneli olmalıdır';
    }

    return null;
  }

  /// Password validation with strength requirements
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş bırakılamaz';
    }

    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır';
    }

    if (value.length > 50) {
      return 'Şifre çok uzun';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Şifrede en az 1 büyük harf olmalıdır';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Şifrede en az 1 küçük harf olmalıdır';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Şifrede en az 1 rakam olmalıdır';
    }

    if (!value.contains(RegExp(r'[@$!%*?&]'))) {
      return 'Şifrede en az 1 özel karakter (@\$!%*?&) olmalıdır';
    }

    return null;
  }

  /// Name validation (first and last name)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad soyad boş bırakılamaz';
    }

    if (value.length < 2) {
      return 'Ad soyad en az 2 karakter olmalıdır';
    }

    if (value.length > 50) {
      return 'Ad soyad çok uzun';
    }

    if (!nameRegex.hasMatch(value.trim())) {
      return 'Geçerli bir ad soyad giriniz';
    }

    return null;
  }

  /// Building name validation
  static String? validateBuildingName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bina adı boş bırakılamaz';
    }

    if (value.length < 3) {
      return 'Bina adı en az 3 karakter olmalıdır';
    }

    if (value.length > 100) {
      return 'Bina adı çok uzun';
    }

    return null;
  }

  /// Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Adres boş bırakılamaz';
    }

    if (value.length < 10) {
      return 'Adres en az 10 karakter olmalıdır';
    }

    if (value.length > 200) {
      return 'Adres çok uzun';
    }

    return null;
  }

  /// Apartment number validation
  static String? validateApartmentNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Daire numarası boş bırakılamaz';
    }

    if (value.length > 10) {
      return 'Daire numarası çok uzun';
    }

    return null;
  }

  /// Amount validation (for dues, payments, etc.)
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tutar boş bırakılamaz';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Geçerli bir tutar giriniz';
    }

    if (amount < 0) {
      return 'Tutar negatif olamaz';
    }

    if (amount > 1000000) {
      return 'Tutar çok büyük';
    }

    return null;
  }

  /// Generic field validation with custom rules
  static String? validateField({
    required String? value,
    required String fieldName,
    int? minLength,
    int? maxLength,
    bool required = true,
    String? customRegex,
    String? customMessage,
  }) {
    if (required && (value == null || value.isEmpty)) {
      return '$fieldName boş bırakılamaz';
    }

    if (value != null) {
      if (minLength != null && value.length < minLength) {
        return '$fieldName en az $minLength karakter olmalıdır';
      }

      if (maxLength != null && value.length > maxLength) {
        return '$fieldName çok uzun';
      }

      if (customRegex != null && !RegExp(customRegex).hasMatch(value)) {
        return customMessage ?? 'Geçerli bir $fieldName giriniz';
      }
    }

    return null;
  }

  /// Password strength indicator (0-4 scale)
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[@$!%*?&]'))) strength++;

    return strength;
  }

  /// Password strength text
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Zayıf';
      case 2:
      case 3:
        return 'Orta';
      case 4:
      case 5:
        return 'Güçlü';
      default:
        return 'Bilinmeyen';
    }
  }

  /// Password strength color
  static Color getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
