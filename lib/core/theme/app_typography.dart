import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'Nunito';

  // Başlıklar - 50+ yaş için optimize edildi
  static const TextStyle h1 = TextStyle(
    fontSize: 32, // +4
    fontWeight: FontWeight.w800, // +100 weight
    height: 1.2, // Daha sık
    fontFamily: fontFamily,
    letterSpacing: 0.5, // Daha iyi okunabilirlik
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 26, // +4
    fontWeight: FontWeight.w800, // +100 weight
    height: 1.2, // Daha sık
    fontFamily: fontFamily,
    letterSpacing: 0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20, // +2
    fontWeight: FontWeight.w700, // +100 weight
    height: 1.3, // Daha sık
    fontFamily: fontFamily,
    letterSpacing: 0.2,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18, // +2
    fontWeight: FontWeight.w700, // +100 weight
    height: 1.3, // Daha sık
    fontFamily: fontFamily,
    letterSpacing: 0.2,
  );

  // Gövde metni - 50+ yaş için optimize edildi
  static const TextStyle body1 = TextStyle(
    fontSize: 17, // +1
    fontWeight: FontWeight.w500, // +100 weight
    height: 1.5, // Daha sık
    fontFamily: fontFamily,
    letterSpacing: 0.1,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 17, // +1
    fontWeight: FontWeight.w700, // +100 weight
    height: 1.5, // Daha sık
    fontFamily: fontFamily,
    letterSpacing: 0.1,
  );

  // Etiket ve küçük metinler - Minimum 16sp
  static const TextStyle label = TextStyle(
    fontSize: 16, // +2 (minimum 16sp)
    fontWeight: FontWeight.w700, // +100 weight
    height: 1.3, // Daha sık
    fontFamily: fontFamily,
    letterSpacing: 0.1,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 16, // +2 (minimum 16sp)
    fontWeight: FontWeight.w500, // +100 weight
    height: 1.3, // Daha sık
    fontFamily: fontFamily,
    letterSpacing: 0.1,
  );

  // Buton metni - Daha büyük ve bold
  static const TextStyle button = TextStyle(
    fontSize: 18, // +1
    fontWeight: FontWeight.w800, // +100 weight
    letterSpacing: 0.3, // Daha fazla spacing
    fontFamily: fontFamily,
  );

  // Yeni: Large body text - Önemli bilgiler için
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 19, // +3
    fontWeight: FontWeight.w600,
    height: 1.4,
    fontFamily: fontFamily,
    letterSpacing: 0.1,
  );

  // Yeni: Small but readable - Yardım metinleri için
  static const TextStyle small = TextStyle(
    fontSize: 15, // Minimum okunabilir
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFamily: fontFamily,
    letterSpacing: 0.1,
  );
}
