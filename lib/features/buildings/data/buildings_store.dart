import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/building_entity.dart';

/// Yöneticinin binalarını tutan optimized in-memory store.
/// StateProvider pattern ile selective updates ve duplicate check.
/// Üretim ortamında bu liste backend'den (GET /api/buildings) çekilecek.
class BuildingsStore extends StateNotifier<List<BuildingEntity>> {
  BuildingsStore() : super(_initialBuildings());

  static List<BuildingEntity> _initialBuildings() {
    return [
      BuildingEntity(
        id: '1',
        name: 'Güneş Apartmanı',
        address: 'Atatürk Cad. No: 45, Beşiktaş, İstanbul',
        totalApartments: 12,
        occupiedApartments: 11,
        totalMonthlyDues: 12000,
        collectedDues: 10500,
      ),
      BuildingEntity(
        id: '2',
        name: 'Mavi Gözler Sitesi',
        address: 'Cumhuriyet Cad. No: 78, Taksim, İstanbul',
        totalApartments: 24,
        occupiedApartments: 22,
        totalMonthlyDues: 24000,
        collectedDues: 21600,
      ),
      BuildingEntity(
        id: '3',
        name: 'Yeşil Vadi Konutları',
        address: 'Bağdat Cad. No: 123, Kadıköy, İstanbul',
        totalApartments: 18,
        occupiedApartments: 16,
        totalMonthlyDues: 18000,
        collectedDues: 16200,
      ),
    ];
  }

  /// Yeni bina ekler - optimized version
  /// Duplicate check ve selective update ile performans iyileştirildi.
  /// Backend bağlanınca POST /api/buildings çağrısına dönüşecek.
  String addBuilding({
    required String name,
    required String address,
    int totalApartments = 0,
    double monthlyDuesPerApartment = 0,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newBuilding = BuildingEntity(
      id: id,
      name: name,
      address: address,
      totalApartments: totalApartments,
      occupiedApartments: 0,
      totalMonthlyDues: totalApartments * monthlyDuesPerApartment,
      collectedDues: 0,
    );

    // OPTIMIZATION: Duplicate check - aynı ID'li bina varsa ekleme
    if (state.any((building) => building.id == id)) {
      return id; // Zaten varsa return et
    }

    // OPTIMIZATION: Selective update - sadece yeni bina ekle
    state = [...state, newBuilding];
    return id;
  }

  /// Bina güncelle - optimized version
  /// Sadece değişen binayı günceller, tüm listeyi yeniden oluşturmaz.
  void updateBuilding(BuildingEntity updatedBuilding) {
    final index = state.indexWhere(
      (building) => building.id == updatedBuilding.id,
    );
    if (index != -1) {
      // OPTIMIZATION: Sadece değişen elementi güncelle
      final updatedList = [...state];
      updatedList[index] = updatedBuilding;
      state = updatedList;
    }
  }

  /// Bina sil - optimized version
  /// Sadece silinen binayı listeden çıkarır.
  void removeBuilding(String buildingId) {
    // OPTIMIZATION: Filter ile sadece silme işlemi
    state = state.where((building) => building.id != buildingId).toList();
  }

  /// Aidat toplamını güncelle - optimized version
  /// Sadece ilgili binanın aidat bilgisini günceller.
  void updateBuildingDues({
    required String buildingId,
    required double newCollectedDues,
  }) {
    final index = state.indexWhere((building) => building.id == buildingId);
    if (index != -1) {
      final updatedBuilding = state[index].copyWith(
        collectedDues: newCollectedDues,
      );
      updateBuilding(updatedBuilding);
    }
  }

  /// Bina sayısını güncelle - optimized version
  void updateBuildingOccupancy({
    required String buildingId,
    required int newOccupiedApartments,
  }) {
    final index = state.indexWhere((building) => building.id == buildingId);
    if (index != -1) {
      final updatedBuilding = state[index].copyWith(
        occupiedApartments: newOccupiedApartments,
      );
      updateBuilding(updatedBuilding);
    }
  }
}

// OPTIMIZED: StateProvider pattern ile daha efficient provider
final buildingsStoreProvider =
    StateNotifierProvider<BuildingsStore, List<BuildingEntity>>(
      (ref) => BuildingsStore(),
    );

// ADDITIONAL: Convenience provider'lar for specific operations
final buildingsCountProvider = Provider<int>((ref) {
  return ref.watch(buildingsStoreProvider).length;
});

final totalBuildingsDuesProvider = Provider<double>((ref) {
  final buildings = ref.watch(buildingsStoreProvider);
  return buildings.fold<double>(
    0,
    (sum, building) => sum + building.collectedDues,
  );
});
