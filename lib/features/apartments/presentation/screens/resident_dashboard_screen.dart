import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';

import '../../../../shared/widgets/settings_tab.dart';
import '../../../../shared/providers/navigation_provider.dart';

import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dues/presentation/screens/my_dues_screen.dart';
import '../../../tickets/presentation/screens/my_tickets_screen.dart';

class ResidentDashboardScreen extends ConsumerStatefulWidget {
  const ResidentDashboardScreen({super.key});

  @override
  ConsumerState<ResidentDashboardScreen> createState() =>
      _ResidentDashboardScreenState();
}

class _ResidentDashboardScreenState
    extends ConsumerState<ResidentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      ref.read(residentTabIndexProvider.notifier).state = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(residentTabIndexProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sakin Ekranı'), centerTitle: true),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildDuesTab(),
          _buildIssuesTab(),
          _buildSettingsTab(),
        ],
      ),

      // 🔥 SADECE ARIZALAR TAB’INDA GÖRÜNÜR
      // floatingActionButton: currentIndex == 2
      //     ? FloatingActionButton(
      //         onPressed: () {
      //           debugPrint("Yeni arıza oluştur");
      //         },
      //         child: const Icon(Icons.add),
      //       )
      //     : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(residentTabIndexProvider.notifier).state = index;
          _tabController.animateTo(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Aidatlar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_outlined),
            label: 'Arızalar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }

  // ---------------- HOME ----------------

  Widget _buildHomeTab() {
    final apartment = _getDummyApartment();
    final authState = ref.watch(authStateProvider);

    final userName = authState.user?.name ?? apartment.residentName;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoş Geldiniz, $userName',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: AppSizes.spacingXS),

          Text(
            'Daire ${apartment.apartmentNumber}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),

          const SizedBox(height: AppSizes.spacingL),

          _buildPaymentStatusCard(apartment),

          const SizedBox(height: AppSizes.spacingL),

          _buildQuickActionsRow(),

          const SizedBox(height: AppSizes.spacingL),

          const Text(
            'Son İşlemler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: AppSizes.spacingM),

          _buildTransactionHistory(),
        ],
      ),
    );
  }

  // ---------------- TABS ----------------

  Widget _buildDuesTab() {
    return const MyDuesScreen();
  }

  Widget _buildIssuesTab() {
    return const MyTicketsScreen(); // 🔥 DOĞRU
  }

  Widget _buildSettingsTab() {
    return const SettingsTab();
  }

  // ---------------- CARD ----------------

  Widget _buildPaymentStatusCard(ApartmentEntity apartment) {
    final statusColor = apartment.paymentStatus == PaymentStatus.paid
        ? AppColors.success
        : apartment.paymentStatus == PaymentStatus.pending
        ? AppColors.warning
        : AppColors.error;

    final statusText = apartment.paymentStatus == PaymentStatus.paid
        ? 'Ödendi'
        : apartment.paymentStatus == PaymentStatus.pending
        ? 'Beklemede'
        : 'Gecikmiş';

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aylık Aidat',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingS,
                  vertical: AppSizes.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: AppTypography.label.copyWith(color: statusColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spacingM),

          Text(
            '₺${apartment.monthlyDues.toStringAsFixed(2)}',
            style: AppTypography.h1.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ---------------- ACTIONS ----------------

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.payment_outlined,
            label: 'Ödeme Yap',
            onTap: () {},
          ),
        ),
        const SizedBox(width: AppSizes.spacingM),
        Expanded(
          child: _buildActionButton(
            icon: Icons.receipt_outlined,
            label: 'Faturalar',
            onTap: () {},
          ),
        ),
        const SizedBox(width: AppSizes.spacingM),
        Expanded(
          child: _buildActionButton(
            icon: Icons.help_outline,
            label: 'Destek',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HISTORY ----------------

  Widget _buildTransactionHistory() {
    return const SizedBox(); // Şimdilik boş
  }

  // ---------------- DUMMY ----------------

  ApartmentEntity _getDummyApartment() {
    return ApartmentEntity(
      id: '1',
      buildingId: '1',
      apartmentNumber: '4B',
      residentName: 'Sakin Adı',
      phone: null,
      monthlyDues: 5000,
      paymentStatus: PaymentStatus.paid,
      lastPaymentDate: DateTime(2024, 4, 15),
      balance: 0,
    );
  }
}
