import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aktif davet kodlarını daire (apartmentId) bazlı tutan basit bellek deposu.
/// Üretim ortamında bunun yerine backend'in InviteCode tablosu kullanılacak.
/// Bir daire için aktif kod varsa (süresi dolmamışsa), yeni kod üretilmesine izin verilmez.
class ActiveInviteCode {
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;

  const ActiveInviteCode({
    required this.code,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remaining => expiresAt.difference(DateTime.now());
}

class InviteCodeStore extends StateNotifier<Map<String, ActiveInviteCode>> {
  InviteCodeStore() : super(const {});

  /// Daire için aktif (süresi dolmamış) kodu döndürür, yoksa null.
  ActiveInviteCode? activeFor(String apartmentId) {
    final entry = state[apartmentId];
    if (entry == null) return null;
    if (entry.isExpired) {
      // Süresi dolmuş — temizle
      final next = Map<String, ActiveInviteCode>.from(state)..remove(apartmentId);
      state = next;
      return null;
    }
    return entry;
  }

  /// Yeni kod kaydeder.
  void save(String apartmentId, ActiveInviteCode entry) {
    state = {...state, apartmentId: entry};
  }

  /// Daire için aktif kodu iptal eder (manager isterse).
  void revoke(String apartmentId) {
    final next = Map<String, ActiveInviteCode>.from(state)..remove(apartmentId);
    state = next;
  }
}

final inviteCodeStoreProvider =
    StateNotifierProvider<InviteCodeStore, Map<String, ActiveInviteCode>>(
  (ref) => InviteCodeStore(),
);
