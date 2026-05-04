import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/apartment_entity.dart';

/// Bina başına daireleri tutan optimized in-memory store.
/// StateProvider pattern ile selective updates ve memory management.
/// Üretim ortamında bu veri backend'den (GET /api/buildings/:id/apartments) çekilecek.
/// `Map<buildingId, List<ApartmentEntity>>`
class ApartmentsStore
    extends StateNotifier<Map<String, List<ApartmentEntity>>> {
  ApartmentsStore() : super(_initialApartments());

  static Map<String, List<ApartmentEntity>> _initialApartments() {
    return {
      '1': [
        ApartmentEntity(
          id: '1-1',
          buildingId: '1',
          apartmentNumber: '1A',
          residentName: 'Ahmet Yılmaz',
          phone: '+905551112233',
          monthlyDues: 1000,
          paymentStatus: PaymentStatus.paid,
          balance: 0,
        ),
        ApartmentEntity(
          id: '1-2',
          buildingId: '1',
          apartmentNumber: '1B',
          residentName: 'Fatma Demir',
          phone: '+905552223344',
          monthlyDues: 1000,
          paymentStatus: PaymentStatus.pending,
          balance: 1000,
        ),
        ApartmentEntity(
          id: '1-3',
          buildingId: '1',
          apartmentNumber: '2A',
          residentName: 'Mehmet Öztürk',
          phone: '+905553334455',
          monthlyDues: 1000,
          paymentStatus: PaymentStatus.overdue,
          balance: 3000,
        ),
        ApartmentEntity(
          id: '1-4',
          buildingId: '1',
          apartmentNumber: '2B',
          residentName: 'Ayşe Kaya',
          phone: '+905554445566',
          monthlyDues: 1000,
          paymentStatus: PaymentStatus.paid,
          balance: 0,
        ),
        ApartmentEntity(
          id: '1-5',
          buildingId: '1',
          apartmentNumber: '3A',
          residentName: 'Boş Daire',
          monthlyDues: 1000,
          paymentStatus: PaymentStatus.pending,
          balance: 0,
        ),
      ],
      '2': [
        ApartmentEntity(
          id: '2-1',
          buildingId: '2',
          apartmentNumber: '1A',
          residentName: 'Ali Veli',
          phone: '+905555556677',
          monthlyDues: 1500,
          paymentStatus: PaymentStatus.paid,
          balance: 0,
        ),
        ApartmentEntity(
          id: '2-2',
          buildingId: '2',
          apartmentNumber: '1B',
          residentName: 'Zeynep Aydın',
          phone: '+905556667788',
          monthlyDues: 1500,
          paymentStatus: PaymentStatus.pending,
          balance: 1500,
        ),
      ],
      '3': [
        ApartmentEntity(
          id: '3-1',
          buildingId: '3',
          apartmentNumber: '1A',
          residentName: 'Hasan Çelik',
          phone: '+905557778899',
          monthlyDues: 1200,
          paymentStatus: PaymentStatus.paid,
          balance: 0,
        ),
        ApartmentEntity(
          id: '3-2',
          buildingId: '3',
          apartmentNumber: '1B',
          residentName: 'Boş Daire',
          monthlyDues: 1200,
          paymentStatus: PaymentStatus.pending,
          balance: 0,
        ),
      ],
    };
  }

  List<ApartmentEntity> apartmentsFor(String buildingId) {
    return state[buildingId] ?? const [];
  }

  /// Yeni bina için otomatik daire üret - optimized version
  /// [floors] = kat sayısı, [apartmentsPerFloor] = her kattaki daire sayısı.
  /// Daireler A, B, C, ... harflerle isimlendirilir (örn: 1A, 1B, 2A, 2B).
  void generateApartmentsForBuilding({
    required String buildingId,
    required int floors,
    required int apartmentsPerFloor,
    required double monthlyDues,
  }) {
    if (floors <= 0 || apartmentsPerFloor <= 0) {
      // OPTIMIZATION: Sadece ilgili binayı güncelle
      state = {...state, buildingId: const []};
      return;
    }

    // OPTIMIZATION: Duplicate check - zaten daireler varsa tekrar üretme
    if (state.containsKey(buildingId) && state[buildingId]!.isNotEmpty) {
      return; // Zaten daireler varsa tekrar üretme
    }

    const allLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final apartments = <ApartmentEntity>[];
    int counter = 1;
    for (int floor = 1; floor <= floors; floor++) {
      for (int i = 0; i < apartmentsPerFloor; i++) {
        final letter = i < allLetters.length
            ? allLetters[i]
            : '${i + 1}'; // 26'dan fazla daire varsa sayıya geç
        apartments.add(
          ApartmentEntity(
            id: '$buildingId-$counter',
            buildingId: buildingId,
            apartmentNumber: '$floor$letter',
            residentName: 'Boş Daire',
            monthlyDues: monthlyDues,
            paymentStatus: PaymentStatus.pending,
            balance: 0,
          ),
        );
        counter++;
      }
    }
    // OPTIMIZATION: Sadece ilgili binayı güncelle
    state = {...state, buildingId: apartments};
  }

  /// Daire güncelle - optimized version
  /// Sadece değişen daireyi günceller, tüm map'i yeniden oluşturmaz.
  void updateApartment(ApartmentEntity updatedApartment) {
    final buildingId = updatedApartment.buildingId;
    final apartments = state[buildingId] ?? [];

    final index = apartments.indexWhere((apt) => apt.id == updatedApartment.id);
    if (index != -1) {
      // OPTIMIZATION: Sadece değişen daireyi güncelle
      final updatedList = [...apartments];
      updatedList[index] = updatedApartment;
      state = {...state, buildingId: updatedList};
    }
  }

  /// Daire ekle - optimized version
  /// Sadece ilgili binaya daire ekler, diğer binaları etkilemez.
  void addApartment(ApartmentEntity apartment) {
    final buildingId = apartment.buildingId;
    final apartments = state[buildingId] ?? [];

    // OPTIMIZATION: Duplicate check
    if (apartments.any((apt) => apt.id == apartment.id)) {
      return; // Zaten varsa ekleme
    }

    // OPTIMIZATION: Sadece ilgili binayı güncelle
    state = {
      ...state,
      buildingId: [...apartments, apartment],
    };
  }

  /// Daire sil - optimized version
  /// Sadece ilgili binadan daire siler, diğer binaları etkilemez.
  void removeApartment(String apartmentId, String buildingId) {
    final apartments = state[buildingId] ?? [];

    // OPTIMIZATION: Filter ile sadece silme işlemi
    final updatedApartments = apartments
        .where((apt) => apt.id != apartmentId)
        .toList();
    state = {...state, buildingId: updatedApartments};
  }

  /// Ödeme durumunu güncelle - optimized version
  /// Sadece ilgili dairenin durumunu günceller.
  void updatePaymentStatus({
    required String apartmentId,
    required String buildingId,
    required PaymentStatus newStatus,
    DateTime? paymentDate,
  }) {
    final apartments = state[buildingId] ?? [];
    final index = apartments.indexWhere((apt) => apt.id == apartmentId);

    if (index != -1) {
      final updatedApartment = apartments[index].copyWith(
        paymentStatus: newStatus,
        lastPaymentDate: paymentDate ?? DateTime.now(),
        balance: newStatus == PaymentStatus.paid
            ? 0
            : apartments[index].balance,
      );
      updateApartment(updatedApartment);
    }
  }

  /// Sakin bilgilerini güncelle - optimized version
  void updateResidentInfo({
    required String apartmentId,
    required String buildingId,
    required String residentName,
    String? phone,
  }) {
    final apartments = state[buildingId] ?? [];
    final index = apartments.indexWhere((apt) => apt.id == apartmentId);

    if (index != -1) {
      final updatedApartment = apartments[index].copyWith(
        residentName: residentName,
        phone: phone,
      );
      updateApartment(updatedApartment);
    }
  }

  /// Bina başına toplam daire sayısı - convenience method
  int getApartmentCount(String buildingId) {
    return state[buildingId]?.length ?? 0;
  }

  /// Bina başına dolu daire sayısı - convenience method
  int getOccupiedCount(String buildingId) {
    final apartments = state[buildingId] ?? [];
    return apartments.where((apt) => apt.residentName != 'Boş Daire').length;
  }

  /// Bina başına ödenmiş aidat sayısı - convenience method
  int getPaidCount(String buildingId) {
    final apartments = state[buildingId] ?? [];
    return apartments
        .where((apt) => apt.paymentStatus == PaymentStatus.paid)
        .length;
  }
}

// OPTIMIZED: StateProvider pattern ile daha efficient provider
final apartmentsStoreProvider =
    StateNotifierProvider<ApartmentsStore, Map<String, List<ApartmentEntity>>>(
      (ref) => ApartmentsStore(),
    );

// ADDITIONAL: Convenience provider'lar for specific operations
final apartmentCountProvider = Provider.family<int, String>((ref, buildingId) {
  final store = ref.watch(apartmentsStoreProvider);
  return store[buildingId]?.length ?? 0;
});

final occupiedCountProvider = Provider.family<int, String>((ref, buildingId) {
  final store = ref.watch(apartmentsStoreProvider);
  final apartments = store[buildingId] ?? [];
  return apartments.where((apt) => apt.residentName != 'Boş Daire').length;
});

final paidCountProvider = Provider.family<int, String>((ref, buildingId) {
  final store = ref.watch(apartmentsStoreProvider);
  final apartments = store[buildingId] ?? [];
  return apartments
      .where((apt) => apt.paymentStatus == PaymentStatus.paid)
      .length;
});
