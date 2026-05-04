import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../utils/invite_code_helpers.dart';

/// Dolu daireye yine de yeni kod üretilmek istendiğinde gösterilen onay dialogu.
class OccupiedApartmentConfirmDialog extends StatelessWidget {
  final ApartmentEntity apartment;
  final VoidCallback onConfirm;

  const OccupiedApartmentConfirmDialog({
    super.key,
    required this.apartment,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: 8),
          const Text('Daire Dolu'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${InviteCodeHelpers.formatApartmentLabel(apartment.apartmentNumber)} dairesinde "${apartment.residentName}" kayıtlı.',
            style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.spacingS),
          RichText(
            text: TextSpan(
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                const TextSpan(text: 'Yeni kod üretirsen '),
                TextSpan(
                  text: 'eski kullanıcı çıkarılır',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: '. Emin misiniz?'),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSizes.spacingM,
        0,
        AppSizes.spacingM,
        AppSizes.spacingM,
      ),
      actions: [
        _DialogActionRow(
          confirmLabel: 'Yine de Üret',
          confirmColor: AppColors.primary,
          onConfirm: () {
            Navigator.pop(context);
            onConfirm();
          },
        ),
      ],
    );
  }
}

/// Aktif kodu iptal etmek için onay dialogu.
class RevokeInviteCodeDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const RevokeInviteCodeDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.cancel_outlined, color: AppColors.error),
          const SizedBox(width: 8),
          const Text('Kodu İptal Et'),
        ],
      ),
      content: RichText(
        text: TextSpan(
          style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
          children: [
            const TextSpan(text: 'Mevcut kod '),
            TextSpan(
              text: 'geçersiz hale gelir',
              style: AppTypography.body2.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            const TextSpan(text: '. Emin misiniz?'),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSizes.spacingM,
        0,
        AppSizes.spacingM,
        AppSizes.spacingM,
      ),
      actions: [
        _DialogActionRow(
          confirmLabel: 'İptal Et',
          confirmColor: AppColors.error,
          onConfirm: () {
            Navigator.pop(context);
            onConfirm();
          },
        ),
      ],
    );
  }
}

/// Vazgeç + onay butonlu yatay aksiyon satırı (dialoglarda kullanılır).
class _DialogActionRow extends StatelessWidget {
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _DialogActionRow({
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightSecondary,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: AppColors.borderColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Vazgeç',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightSecondary,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onConfirm,
              child: Text(
                confirmLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
