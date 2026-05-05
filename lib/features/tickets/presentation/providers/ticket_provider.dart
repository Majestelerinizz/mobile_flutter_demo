import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ticket_entity.dart';

enum TicketFilter { all, open, inProgress, resolved }

final ticketFilterProvider = StateProvider<TicketFilter>((ref) {
  return TicketFilter.all;
});

final ticketProvider =
    StateNotifierProvider<TicketNotifier, List<TicketEntity>>((ref) {
      return TicketNotifier();
    });

class TicketNotifier extends StateNotifier<List<TicketEntity>> {
  TicketNotifier()
    : super([
        TicketEntity(
          id: '1',
          title: 'Asansör bozuk',
          description: '3 gündür çalışmıyor',
          createdAt: DateTime(2026, 5, 1),
          status: TicketStatus.open,
        ),
        TicketEntity(
          id: '2',
          title: 'Su kesintisi',
          description: 'Basınç çok düşük geliyor',
          createdAt: DateTime(2026, 5, 3),
          status: TicketStatus.inProgress,
        ),
        TicketEntity(
          id: '3',
          title: 'Kapı arızası',
          description: 'Apartman giriş kapısı kapanmıyor',
          createdAt: DateTime(2026, 5, 4),
          status: TicketStatus.resolved,
        ),
      ]);

  void addTicket({required String title, required String description}) {
    final newTicket = TicketEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      status: TicketStatus.open,
    );

    state = [newTicket, ...state];
  }
}
