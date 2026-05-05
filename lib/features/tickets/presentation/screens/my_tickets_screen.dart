import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/ticket_entity.dart';
import '../providers/ticket_provider.dart';

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(ticketFilterProvider);
    final tickets = ref.watch(ticketProvider);

    final filtered = selectedFilter == TicketFilter.all
        ? tickets
        : tickets.where((t) => _mapStatus(t.status) == selectedFilter).toList();

    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arızalarım',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingM),
                _buildFilters(ref, selectedFilter),
                const SizedBox(height: AppSizes.spacingL),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'Henüz arıza yok',
                            style: AppTypography.body1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) =>
                              _buildCard(filtered[index]),
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            right: AppSizes.spacingL,
            bottom: AppSizes.spacingL,
            child: FloatingActionButton(
              onPressed: () => _showCreateTicketSheet(context, ref),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(WidgetRef ref, TicketFilter selectedFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(ref, 'Tümü', TicketFilter.all, selectedFilter),
          _chip(ref, 'Açık', TicketFilter.open, selectedFilter),
          _chip(ref, 'İşlemde', TicketFilter.inProgress, selectedFilter),
          _chip(ref, 'Çözüldü', TicketFilter.resolved, selectedFilter),
        ],
      ),
    );
  }

  Widget _chip(
    WidgetRef ref,
    String label,
    TicketFilter filter,
    TicketFilter selectedFilter,
  ) {
    final selected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          ref.read(ticketFilterProvider.notifier).state = filter;
        },
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: AppTypography.label.copyWith(
          color: selected ? Colors.white : AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.borderColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(TicketEntity t) {
    final color = _getColor(t.status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title, style: AppTypography.h4),
                const SizedBox(height: 4),
                Text(t.description, style: AppTypography.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacingM),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _statusText(t.status),
              style: AppTypography.label.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTicketSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSizes.spacingL,
            right: AppSizes.spacingL,
            top: AppSizes.spacingL,
            bottom:
                MediaQuery.of(sheetContext).viewInsets.bottom +
                AppSizes.spacingL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yeni Arıza Oluştur',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSizes.spacingM),

              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'Örn: Asansör bozuk',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: AppSizes.spacingM),

              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Sorunu kısaca açıklayın',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: AppSizes.spacingL),

              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightPrimary,
                child: ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();

                    if (title.isEmpty || description.isEmpty) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(
                          content: Text('Başlık ve açıklama boş olamaz'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(sheetContext);

                    Future.microtask(() {
                      ref
                          .read(ticketProvider.notifier)
                          .addTicket(title: title, description: description);
                    });
                  },
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TicketFilter _mapStatus(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return TicketFilter.open;
      case TicketStatus.inProgress:
        return TicketFilter.inProgress;
      case TicketStatus.resolved:
        return TicketFilter.resolved;
    }
  }

  String _statusText(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return 'Açık';
      case TicketStatus.inProgress:
        return 'İşlemde';
      case TicketStatus.resolved:
        return 'Çözüldü';
    }
  }

  Color _getColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return AppColors.error;
      case TicketStatus.inProgress:
        return AppColors.warning;
      case TicketStatus.resolved:
        return AppColors.success;
    }
  }
}
