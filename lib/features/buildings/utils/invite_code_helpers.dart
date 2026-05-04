import 'dart:math';

import '../../apartments/domain/entities/apartment_entity.dart';
import '../domain/entities/building_entity.dart';

/// Davet kodu özelliği için yardımcı saf fonksiyonlar.
class InviteCodeHelpers {
  InviteCodeHelpers._();

  /// "1A" → "1. Kat - Daire A", "12" → "12. Kat"
  static String formatApartmentLabel(String apartmentNumber) {
    final match = RegExp(r'(\d+)([A-Za-z]?)').firstMatch(apartmentNumber);
    if (match == null) return apartmentNumber;
    final floor = match.group(1);
    final letter = match.group(2);
    if (letter != null && letter.isNotEmpty) {
      return '$floor. Kat - Daire $letter';
    }
    return '$floor. Kat';
  }

  /// DateTime → "06.05.2026"
  static String formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }

  /// Süre: "5 gün 3 saat", "12 saat 30 dk", "45 dk", "Süresi doldu"
  static String remainingText(Duration d) {
    if (d.isNegative) return 'Süresi doldu';
    if (d.inDays > 0) {
      final hours = d.inHours - d.inDays * 24;
      return hours > 0 ? '${d.inDays} gün $hours saat' : '${d.inDays} gün';
    }
    if (d.inHours > 0) {
      final mins = d.inMinutes - d.inHours * 60;
      return mins > 0 ? '${d.inHours} saat $mins dk' : '${d.inHours} saat';
    }
    return '${d.inMinutes} dk';
  }

  /// Yeni davet kodu üretir.
  /// Format: "AP{binaKodu}-{daireNo}-{rastgele4}"  (örn: "AP425-1A-X7K9")
  /// - AP: Sabit "Apartman" prefix (plan'a uygun)
  /// - binaKodu: Bina ID'sinden türetilmiş 3 haneli stabil numara
  /// - daireNo: Daire numarası (1A, 2B, vb.)
  /// - rastgele4: Güvenlik için 4 karakter alfanumerik
  static String generateCode(BuildingEntity b, ApartmentEntity a) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    String pick(int n) =>
        List.generate(n, (_) => chars[rnd.nextInt(chars.length)]).join();

    // Bina ID'sinden stabil 3 haneli numara (0-999 arası)
    final shortBuildingId = (b.id.hashCode.abs() % 1000).toString().padLeft(
      3,
      '0',
    );

    return 'AP$shortBuildingId-${a.apartmentNumber.toUpperCase()}-${pick(4)}';
  }

  /// Paylaşılacak mesajı oluşturur.
  static String buildShareMessage({
    required String code,
    required BuildingEntity building,
    required ApartmentEntity apartment,
    required DateTime expiresAt,
  }) {
    return 'AidatPanel davet kodu\n\n'
        'Bina: ${building.name}\n'
        'Daire: ${formatApartmentLabel(apartment.apartmentNumber)}\n'
        'Kod: $code\n\n'
        'Son kullanma: ${formatDate(expiresAt)} (7 gün geçerli)\n\n'
        'AidatPanel uygulamasını indirip kayıt olurken bu kodu kullanabilirsiniz.';
  }
}
