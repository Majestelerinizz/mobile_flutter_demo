/// Auth validasyon yardımcı fonksiyonları
/// Tüm validasyon mantıkları bu class içinde toplanmıştır
class AuthValidators {
  AuthValidators._();

  /// Email format kontrolü
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Telefon numarası format kontrolü (5 ile başlayan 10 haneli)
  static bool isValidPhone(String phone) {
    return RegExp(r'^5[0-9]{9}$').hasMatch(phone);
  }

  /// Davet kodu format kontrolü (AP3-B12-X7K9 formatı)
  static bool isValidInviteCode(String code) {
    return RegExp(r'^[A-Z0-9]{2,4}-[A-Z0-9]{2,4}-[A-Z0-9]{4,6}$').hasMatch(code);
  }

  /// Şifre uzunluk kontrolü (minimum 6 karakter)
  static bool isValidPasswordLength(String password) {
    return password.length >= 6;
  }

  /// Şifre karmaşıklık kontrolü (opsiyonel - ileride eklenebilir)
  static bool isStrongPassword(String password) {
    // En az 6 karakter, en az 1 harf, en az 1 sayı
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{6,}$').hasMatch(password);
  }
}
