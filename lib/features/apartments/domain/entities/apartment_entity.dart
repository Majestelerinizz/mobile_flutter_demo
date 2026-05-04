import 'package:equatable/equatable.dart';

enum PaymentStatus { paid, pending, overdue }

class ApartmentEntity extends Equatable {
  final String id;
  final String buildingId;
  final String apartmentNumber;
  final String residentName;
  final String? phone;
  final double monthlyDues;
  final PaymentStatus paymentStatus;
  final DateTime? lastPaymentDate;
  final double balance;

  const ApartmentEntity({
    required this.id,
    required this.buildingId,
    required this.apartmentNumber,
    required this.residentName,
    this.phone,
    required this.monthlyDues,
    required this.paymentStatus,
    this.lastPaymentDate,
    required this.balance,
  });

  /// Immutable update için copyWith method
  /// Optimized state management için gerekli
  ApartmentEntity copyWith({
    String? id,
    String? buildingId,
    String? apartmentNumber,
    String? residentName,
    String? phone,
    double? monthlyDues,
    PaymentStatus? paymentStatus,
    DateTime? lastPaymentDate,
    double? balance,
  }) {
    return ApartmentEntity(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      residentName: residentName ?? this.residentName,
      phone: phone ?? this.phone,
      monthlyDues: monthlyDues ?? this.monthlyDues,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      balance: balance ?? this.balance,
    );
  }

  @override
  List<Object?> get props => [
    id,
    buildingId,
    apartmentNumber,
    residentName,
    phone,
    monthlyDues,
    paymentStatus,
    lastPaymentDate,
    balance,
  ];
}
