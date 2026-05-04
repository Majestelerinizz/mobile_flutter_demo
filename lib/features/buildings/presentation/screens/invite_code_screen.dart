import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../data/invite_code_store.dart';
import '../../domain/entities/building_entity.dart';
import '../../utils/invite_code_helpers.dart';
import '../widgets/invite_code_result_view.dart';
import '../widgets/invite_confirm_dialogs.dart';
import '../widgets/invite_selectable_tile.dart';
import '../widgets/invite_step_indicator.dart';

/// Davet kodu üretme akışı (3 adım): Bina → Daire → Kod.
class InviteCodeScreen extends ConsumerStatefulWidget {
  final List<BuildingEntity> buildings;
  final List<ApartmentEntity> Function(String buildingId) apartmentsLoader;

  const InviteCodeScreen({
    super.key,
    required this.buildings,
    required this.apartmentsLoader,
  });

  @override
  ConsumerState<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends ConsumerState<InviteCodeScreen> {
  static const _validityDays = 7;

  int _step = 0;
  BuildingEntity? _selectedBuilding;
  ApartmentEntity? _selectedApartment;
  String? _generatedCode;
  DateTime? _activeExpiresAt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Davet Kodu Oluştur'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBackPressed,
        ),
      ),
      body: Column(
        children: [
          InviteStepIndicator(currentStep: _step),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _BuildingPickerStep(
          key: const ValueKey('step-0'),
          buildings: widget.buildings,
          onPick: _onBuildingPicked,
        );
      case 1:
        return _ApartmentPickerStep(
          key: const ValueKey('step-1'),
          building: _selectedBuilding!,
          apartments: widget.apartmentsLoader(_selectedBuilding!.id),
          onPick: _onApartmentSelected,
          activeCodes: ref.watch(inviteCodeStoreProvider),
        );
      case 2:
        return InviteCodeResultView(
          key: const ValueKey('step-2'),
          code: _generatedCode!,
          building: _selectedBuilding!,
          apartment: _selectedApartment!,
          expiresAt: _activeExpiresAt!,
          onCopy: () => _copyCode(_generatedCode!),
          onShare: () => _shareCode(),
          onRevoke: _confirmRevoke,
          onPickAnother: _resetFlow,
          onGoHome: () => Navigator.pop(context),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------- AKIŞ ----------
  void _onBuildingPicked(BuildingEntity b) {
    setState(() {
      _selectedBuilding = b;
      _selectedApartment = null;
      _step = 1;
    });
  }

  void _onApartmentSelected(ApartmentEntity apt) {
    final active = ref.read(inviteCodeStoreProvider.notifier).activeFor(apt.id);
    if (active != null) {
      _showActiveCode(apt, active);
      return;
    }
    if (apt.phone != null) {
      showDialog<void>(
        context: context,
        builder: (_) => OccupiedApartmentConfirmDialog(
          apartment: apt,
          onConfirm: () => _generateAndShow(apt),
        ),
      );
    } else {
      _generateAndShow(apt);
    }
  }

  void _showActiveCode(ApartmentEntity apt, ActiveInviteCode active) {
    setState(() {
      _selectedApartment = apt;
      _generatedCode = active.code;
      _activeExpiresAt = active.expiresAt;
      _step = 2;
    });
  }

  void _generateAndShow(ApartmentEntity apt) {
    final code = InviteCodeHelpers.generateCode(_selectedBuilding!, apt);
    final now = DateTime.now();
    final expires = now.add(const Duration(days: _validityDays));
    ref.read(inviteCodeStoreProvider.notifier).save(
          apt.id,
          ActiveInviteCode(code: code, createdAt: now, expiresAt: expires),
        );
    setState(() {
      _selectedApartment = apt;
      _generatedCode = code;
      _activeExpiresAt = expires;
      _step = 2;
    });
  }

  void _confirmRevoke() {
    final apt = _selectedApartment!;
    showDialog<void>(
      context: context,
      builder: (_) => RevokeInviteCodeDialog(
        onConfirm: () {
          ref.read(inviteCodeStoreProvider.notifier).revoke(apt.id);
          ref
              .read(toastProvider.notifier)
              .show('Kod iptal edildi', type: ToastType.success);
          _resetFlow();
        },
      ),
    );
  }

  void _resetFlow() {
    setState(() {
      _step = 0;
      _selectedBuilding = null;
      _selectedApartment = null;
      _generatedCode = null;
      _activeExpiresAt = null;
    });
  }

  void _onBackPressed() {
    if (_step == 0) {
      Navigator.pop(context);
    } else if (_step == 1) {
      setState(() {
        _step = 0;
        _selectedBuilding = null;
      });
    } else {
      setState(() {
        _step = 1;
        _selectedApartment = null;
        _generatedCode = null;
        _activeExpiresAt = null;
      });
    }
  }

  // ---------- AKSİYONLAR ----------
  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ref
        .read(toastProvider.notifier)
        .show('Kod kopyalandı: $code', type: ToastType.success);
  }

  Future<void> _shareCode() async {
    final message = InviteCodeHelpers.buildShareMessage(
      code: _generatedCode!,
      building: _selectedBuilding!,
      apartment: _selectedApartment!,
      expiresAt: _activeExpiresAt!,
    );

    try {
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          subject: 'AidatPanel Davet Kodu',
          sharePositionOrigin: box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        ),
      );
    } catch (_) {
      Clipboard.setData(ClipboardData(text: message));
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show('Mesaj panoya kopyalandı', type: ToastType.info);
      }
    }
  }
}

// ============================================================================
//  ADIM 1: BİNA SEÇİMİ
// ============================================================================
class _BuildingPickerStep extends StatelessWidget {
  final List<BuildingEntity> buildings;
  final ValueChanged<BuildingEntity> onPick;

  const _BuildingPickerStep({
    super.key,
    required this.buildings,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    // OPTIMIZATION: ListView.builder kullanılıyor (lazy loading)
    // Büyük bina listelerinde memory efficient, scroll performance artar
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacingL),
      itemCount: buildings.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
            child: Text(
              'Hangi binadan kod üretilecek?',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
          );
        }
        final b = buildings[index - 1];
        return InviteSelectableTile(
          icon: Icons.apartment,
          iconColor: AppColors.primary,
          title: b.name,
          subtitle: b.address,
          onTap: () => onPick(b),
        );
      },
    );
  }
}

// ============================================================================
//  ADIM 2: DAİRE SEÇİMİ
// ============================================================================
class _ApartmentPickerStep extends StatelessWidget {
  final BuildingEntity building;
  final List<ApartmentEntity> apartments;
  final Map<String, ActiveInviteCode> activeCodes;
  final ValueChanged<ApartmentEntity> onPick;

  const _ApartmentPickerStep({
    super.key,
    required this.building,
    required this.apartments,
    required this.activeCodes,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    // OPTIMIZATION: ListView.builder kullanılıyor (lazy loading)
    // 50+ daireli binalarda scroll lag ve memory spike'ı önler
    // 50+ yaş kullanıcılar için kritik performans iyileştirmesi
    if (apartments.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppSizes.spacingL),
        children: [
          _buildBuildingBanner(),
          const SizedBox(height: AppSizes.spacingL),
          Text(
            'Hangi daire için kod üretilecek?',
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.spacingM),
          _buildEmptyState(),
        ],
      );
    }

    // Header: banner + başlık (2 sabit item)
    // Items: apartments
    const headerCount = 3;
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacingL),
      itemCount: apartments.length + headerCount,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacingL),
            child: _buildBuildingBanner(),
          );
        }
        if (index == 1) {
          return Text(
            'Hangi daire için kod üretilecek?',
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          );
        }
        if (index == 2) {
          return const SizedBox(height: AppSizes.spacingM);
        }
        final apt = apartments[index - headerCount];
        return _buildApartmentTile(apt);
      },
    );
  }

  Widget _buildBuildingBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.apartment, color: AppColors.primary),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Text(
              building.name,
              style: AppTypography.body1.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApartmentTile(ApartmentEntity apt) {
    final isOccupied = apt.phone != null;
    final activeCode = activeCodes[apt.id];
    final hasActiveCode = activeCode != null && !activeCode.isExpired;

    final tileIcon = hasActiveCode
        ? Icons.qr_code_2
        : Icons.door_front_door_outlined;
    final tileColor = hasActiveCode
        ? AppColors.accent
        : (isOccupied ? AppColors.textSecondary : AppColors.success);
    final subtitle = hasActiveCode
        ? 'Aktif kod: ${activeCode.code} • ${InviteCodeHelpers.remainingText(activeCode.remaining)}'
        : (isOccupied ? 'Sakin: ${apt.residentName}' : 'Boş daire');

    return InviteSelectableTile(
      icon: tileIcon,
      iconColor: tileColor,
      title: InviteCodeHelpers.formatApartmentLabel(apt.apartmentNumber),
      subtitle: subtitle,
      trailing: _StatusBadge(
        hasActiveCode: hasActiveCode,
        isOccupied: isOccupied,
      ),
      onTap: () => onPick(apt),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.door_back_door_outlined,
            size: 56,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            'Bu binaya henüz daire eklenmemiş',
            style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool hasActiveCode;
  final bool isOccupied;

  const _StatusBadge({
    required this.hasActiveCode,
    required this.isOccupied,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolveBadge();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  (String, Color) _resolveBadge() {
    if (hasActiveCode) return ('Aktif Kod', AppColors.accent);
    if (isOccupied) return ('Dolu', AppColors.warning);
    return ('Boş', AppColors.success);
  }
}
