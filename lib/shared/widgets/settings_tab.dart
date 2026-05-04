import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import 'toast_overlay.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (user != null) _ProfileCard(user: user),
          const SizedBox(height: AppSizes.spacingL),

          _SectionHeader(title: 'Hesap'),
          const SizedBox(height: AppSizes.spacingS),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.lock_outline,
                title: 'Şifre Değiştir',
                onTap: () => _showComingSoon(ref),
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.language,
                title: 'Dil',
                trailing: 'Türkçe',
                onTap: () => _showLanguageComingSoon(ref),
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Bildirimler',
                onTap: () => _showComingSoon(ref),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingL),

          _SectionHeader(title: 'Bilgi'),
          const SizedBox(height: AppSizes.spacingS),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Gizlilik Politikası',
                onTap: () => _showComingSoon(ref),
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: 'KVKK',
                onTap: () => _showComingSoon(ref),
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Yardım & Destek',
                onTap: () => _showComingSoon(ref),
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Hakkında',
                trailing: 'v${AppConstants.appVersion}',
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingXL),

          // Token expiry test button (DEBUG ONLY - production'da gizli)
          if (kDebugMode) ...[
            _TokenTestButton(),
            const SizedBox(height: AppSizes.spacingM),
          ],

          _LogoutButton(),
          const SizedBox(height: AppSizes.spacingL),
        ],
      ),
    );
  }

  void _showComingSoon(WidgetRef ref) {
    ref
        .read(toastProvider.notifier)
        .show('Bu özellik yakında eklenecek', type: ToastType.info);
  }

  void _showLanguageComingSoon(WidgetRef ref) {
    ref
        .read(toastProvider.notifier)
        .show('Çoklu dil desteği yakında eklenecek', type: ToastType.info);
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: 'v${AppConstants.appVersion}',
      applicationLegalese: '© 2026 AidatPanel\nTüm hakları saklıdır.',
      children: [
        const SizedBox(height: AppSizes.spacingM),
        Text(
          'Türk apartman ve site yöneticileri için aidat yönetim platformu.',
          style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserEntity user;

  const _ProfileCard({required this.user});

  String get _initials {
    final parts = user.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : '?';
  }

  String get _roleLabel => user.role == UserRole.manager ? 'Yönetici' : 'Sakin';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary,
            child: Text(
              _initials,
              style: AppTypography.h2.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.spacingXS),
                Text(
                  user.email,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.phone != null && user.phone!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spacingXS),
                  Text(
                    user.phone!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.spacingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _roleLabel,
                    style: AppTypography.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingS),
      child: Text(
        title,
        style: AppTypography.label.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingM,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppSizes.iconSize, color: AppColors.primary),
            const SizedBox(width: AppSizes.spacingM),
            Expanded(
              child: Text(
                title,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
            ],
            const Icon(
              Icons.chevron_right,
              size: AppSizes.iconSize,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return ElevatedButton.icon(
      onPressed: authState.isLoading
          ? null
          : () => _confirmLogout(context, ref),
      icon: const Icon(Icons.logout, size: AppSizes.iconSize),
      label: const Text('Çıkış Yap'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeightPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        ),
        textStyle: AppTypography.button,
        elevation: 0,
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Çıkış Yap', style: AppTypography.h3),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: AppTypography.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authStateProvider.notifier).logout();
              if (!context.mounted) return;
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Çıkış Yap', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _TokenTestButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => _checkTokenExpiry(context, ref),
      icon: const Icon(Icons.timer_outlined, size: AppSizes.iconSize),
      label: const Text('Token Süresi Kontrol (Test)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeightPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        ),
        textStyle: AppTypography.button,
        elevation: 0,
      ),
    );
  }

  Future<void> _checkTokenExpiry(BuildContext context, WidgetRef ref) async {
    final secureStorage = ref.read(secureStorageProvider);
    final isExpired = await secureStorage.isTokenExpired();
    final expiry = await secureStorage.getTokenExpiry();

    if (!context.mounted) return;

    if (isExpired) {
      ref
          .read(toastProvider.notifier)
          .show(
            'Token süresi DOLMUŞ! Login ekranına atılıyorsunuz.',
            type: ToastType.error,
          );
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        context.go('/login');
      }
    } else {
      final remaining = expiry?.difference(DateTime.now()) ?? Duration.zero;
      ref
          .read(toastProvider.notifier)
          .show(
            'Token aktif! Kalan süre: ${remaining.inSeconds} saniye',
            type: ToastType.success,
          );
    }
  }
}
