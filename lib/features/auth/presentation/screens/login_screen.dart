import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../shared/widgets/alt_action_button.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _identifierController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _usePhoneLogin = false;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleLoginMode() {
    setState(() {
      _usePhoneLogin = !_usePhoneLogin;
      _identifierController.clear();
    });
  }

  void _handleLogin() {
    final raw = _identifierController.text.trim();
    final password = _passwordController.text;

    // Input validation
    String? identifierError;
    String? passwordError;

    if (_usePhoneLogin) {
      identifierError = InputValidators.validatePhone(raw);
    } else {
      identifierError = InputValidators.validateEmail(raw);
    }

    passwordError = password.isEmpty ? 'Şifre gerekli' : null;

    // Show validation errors
    if (identifierError != null || passwordError != null) {
      String errorMessage = '';
      if (identifierError != null) {
        errorMessage += identifierError;
      }
      if (passwordError != null) {
        if (errorMessage.isNotEmpty) errorMessage += '\n';
        errorMessage += passwordError;
      }

      ref
          .read(toastProvider.notifier)
          .show(errorMessage, type: ToastType.error);
      return;
    }

    final identifier = _usePhoneLogin ? '+90$raw' : raw;
    ref.read(authStateProvider.notifier).login(identifier, password);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (previous, next) {
      if (next.isAuthenticated) {
        if (next.user?.role.name == 'manager') {
          context.go('/manager-dashboard');
        } else {
          context.go('/resident-dashboard');
        }
      } else if (next.error != null) {
        ref
            .read(toastProvider.notifier)
            .show(next.error ?? 'Bir hata oluştu', type: ToastType.error);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'AidatPanel',
                textAlign: TextAlign.center,
                style: AppTypography.h1.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              Text(
                'Apartman Yönetim Sistemi',
                textAlign: TextAlign.center,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.spacingL),
              Text(
                'Giriş Yap',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSizes.spacingL),
              TextField(
                controller: _identifierController,
                enabled: !authState.isLoading,
                keyboardType: _usePhoneLogin
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                maxLength: _usePhoneLogin ? 10 : null,
                inputFormatters: _usePhoneLogin
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : null,
                style: AppTypography.body1,
                decoration: InputDecoration(
                  labelText: _usePhoneLogin ? 'Telefon' : 'Email',
                  hintText: _usePhoneLogin
                      ? '5XX XXX XX XX'
                      : 'ornek@email.com',
                  prefixText: _usePhoneLogin ? '+90 ' : null,
                  prefixIcon: Icon(
                    _usePhoneLogin
                        ? Icons.phone_outlined
                        : Icons.email_outlined,
                    size: AppSizes.iconSize,
                  ),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingM,
                    vertical: AppSizes.spacingM,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              TextField(
                controller: _passwordController,
                enabled: !authState.isLoading,
                obscureText: _obscurePassword,
                style: AppTypography.body1,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  hintText: '••••••••',
                  prefixIcon: Icon(
                    Icons.lock_outlined,
                    size: AppSizes.iconSize,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: AppSizes.iconSize,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    iconSize: AppSizes.iconTouchTarget,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingM,
                    vertical: AppSizes.spacingM,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingL),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleLogin,
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Giriş Yap'),
              ),
              const SizedBox(height: AppSizes.spacingM),
              OutlinedButton.icon(
                onPressed: authState.isLoading ? null : _toggleLoginMode,
                icon: Icon(
                  _usePhoneLogin
                      ? Icons.email_outlined
                      : Icons.phone_iphone_outlined,
                  size: 20,
                ),
                label: Text(
                  _usePhoneLogin
                      ? 'Email ile Giriş Yap'
                      : 'Telefon ile Giriş Yap',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spacingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  ),
                  textStyle: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingL),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: AppColors.border, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingM,
                    ),
                    child: Text(
                      'veya',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: AppColors.border, thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingL),
              AltActionButton(
                icon: Icons.person_add_outlined,
                title: 'Hesabınız yok mu? Kaydolun',
                onTap: authState.isLoading
                    ? null
                    : () => context.push('/register'),
                isEnabled: !authState.isLoading,
              ),
              const SizedBox(height: AppSizes.spacingM),
              AltActionButton(
                icon: Icons.vpn_key_outlined,
                title: 'Davet kodu ile katılın',
                onTap: authState.isLoading ? null : () => context.push('/join'),
                isEnabled: !authState.isLoading,
              ),
              const SizedBox(height: AppSizes.spacingXL),
              Text(
                '© Vefa Yazılım  v${AppConstants.appVersion}',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
