enum DueStatus { paid, pending, overdue }

class DueEntity {
  final String month;
  final double amount;
  final DueStatus status;

  const DueEntity({
    required this.month,
    required this.amount,
    required this.status,
  });
}
