import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';

/// Davet kodu akışı için 3 adımlı görsel adım göstergesi.
class InviteStepIndicator extends StatelessWidget {
  final int currentStep;

  const InviteStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('Bina', Icons.apartment),
      ('Daire', Icons.door_front_door_outlined),
      ('Kod', Icons.qr_code_2),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingL,
        vertical: AppSizes.spacingM,
      ),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final lineActive = currentStep >= (i ~/ 2) + 1;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: lineActive ? AppColors.primary : AppColors.borderColor,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final active = currentStep >= stepIndex;
          final (label, icon) = steps[stepIndex];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.borderColor,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 18,
                  color: active ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: active ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
