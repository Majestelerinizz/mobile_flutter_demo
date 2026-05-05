import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/due_entity.dart';

enum DueFilter { all, paid, pending, overdue }

class MyDuesScreen extends StatefulWidget {
  const MyDuesScreen({super.key});

  @override
  State<MyDuesScreen> createState() => _MyDuesScreenState();
}

class _MyDuesScreenState extends State<MyDuesScreen> {
  DueFilter selectedFilter = DueFilter.all;

  final dues = const [
    DueEntity(month: 'Mart 2026', amount: 5000, status: DueStatus.overdue),
    DueEntity(month: 'Nisan 2026', amount: 5000, status: DueStatus.paid),
    DueEntity(month: 'Mayıs 2026', amount: 5000, status: DueStatus.pending),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDues = selectedFilter == DueFilter.all
        ? dues
        : dues
              .where((due) => _mapStatus(due.status) == selectedFilter)
              .toList();

    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aidatlarım',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.spacingM),

          _buildFilterChips(),

          const SizedBox(height: AppSizes.spacingL),

          Expanded(
            child: ListView.separated(
              itemCount: filteredDues.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSizes.spacingM),
              itemBuilder: (context, index) {
                final due = filteredDues[index];

                return _buildDueCard(
                  title: due.month,
                  amount: '₺${due.amount}',
                  status: _getStatusText(due.status),
                  statusColor: _getStatusColor(_mapStatus(due.status)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('Tümü', DueFilter.all),
          const SizedBox(width: AppSizes.spacingS),
          _buildFilterChip('Ödendi', DueFilter.paid),
          const SizedBox(width: AppSizes.spacingS),
          _buildFilterChip('Beklemede', DueFilter.pending),
          const SizedBox(width: AppSizes.spacingS),
          _buildFilterChip('Gecikmiş', DueFilter.overdue),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, DueFilter filter) {
    final isSelected = selectedFilter == filter;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          selectedFilter = filter;
        });
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: AppTypography.label.copyWith(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDueCard({
    required String title,
    required String amount,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.h4),
              const SizedBox(height: 4),
              Text(amount, style: AppTypography.body1),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: AppTypography.label.copyWith(color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DueFilter filter) {
    switch (filter) {
      case DueFilter.paid:
        return AppColors.success;
      case DueFilter.pending:
        return AppColors.warning;
      case DueFilter.overdue:
        return AppColors.error;
      case DueFilter.all:
        return AppColors.textSecondary;
    }
  }
}

DueFilter _mapStatus(DueStatus status) {
  switch (status) {
    case DueStatus.paid:
      return DueFilter.paid;
    case DueStatus.pending:
      return DueFilter.pending;
    case DueStatus.overdue:
      return DueFilter.overdue;
  }

  return DueFilter.all; // 🔥 fallback
}

String _getStatusText(DueStatus status) {
  switch (status) {
    case DueStatus.paid:
      return 'Ödendi';
    case DueStatus.pending:
      return 'Beklemede';
    case DueStatus.overdue:
      return 'Gecikmiş';
  }

  return ''; // 🔥 fallback
}
