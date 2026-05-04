import 'package:equatable/equatable.dart';

class BuildingEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final int totalApartments;
  final int occupiedApartments;
  final double totalMonthlyDues;
  final double collectedDues;

  const BuildingEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.totalApartments,
    required this.occupiedApartments,
    required this.totalMonthlyDues,
    required this.collectedDues,
  });

  double get collectionRate {
    if (totalMonthlyDues == 0) return 0;
    return (collectedDues / totalMonthlyDues) * 100;
  }

  /// Immutable update için copyWith method
  /// Optimized state management için gerekli
  BuildingEntity copyWith({
    String? id,
    String? name,
    String? address,
    int? totalApartments,
    int? occupiedApartments,
    double? totalMonthlyDues,
    double? collectedDues,
  }) {
    return BuildingEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      totalApartments: totalApartments ?? this.totalApartments,
      occupiedApartments: occupiedApartments ?? this.occupiedApartments,
      totalMonthlyDues: totalMonthlyDues ?? this.totalMonthlyDues,
      collectedDues: collectedDues ?? this.collectedDues,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    totalApartments,
    occupiedApartments,
    totalMonthlyDues,
    collectedDues,
  ];
}
