enum TicketStatus { open, inProgress, resolved }

class TicketEntity {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final TicketStatus status;

  const TicketEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.status,
  });
}
