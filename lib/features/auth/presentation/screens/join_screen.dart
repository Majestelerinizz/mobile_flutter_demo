import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/utils/auth_validators.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../shared/widgets/alt_action_button.dart';
import '../../../../shared/widgets/password_field.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../providers/auth_provider.dart';

class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  late TextEditingController _inviteCodeController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _inviteCodeError;
  String? _phoneError;
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _inviteCodeController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Widget _buildCriterion(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _handleJoin() {
    final inviteCode = _inviteCodeController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (inviteCode.isEmpty || name.isEmpty || password.isEmpty) {
      ref
          .read(toastProvider.notifier)
          .show(
            'Davet kodu, ad ve şifre boş bırakılamaz',
            type: ToastType.error,
          );
      return;
    }

    if (!AuthValidators.isValidInviteCode(inviteCode)) {
      ref
          .read(toastProvider.notifier)
          .show(
            'Geçersiz davet kodu formatı (Örn: AP3-B12-X7K9)',
            type: ToastType.error,
          );
      return;
    }

    if (phone.isNotEmpty && !AuthValidators.isValidPhone(phone)) {
      ref
          .read(toastProvider.notifier)
          .show(
            'Geçerli bir telefon numarası giriniz (5XX XXX XX XX)',
            type: ToastType.error,
          );
      return;
    }

    if (password != confirmPassword) {
      ref
          .read(toastProvider.notifier)
          .show('Şifreler eşleşmiyor', type: ToastType.error);
      return;
    }

    final passwordError = InputValidators.validatePassword(password);
    if (passwordError != null) {
      ref
          .read(toastProvider.notifier)
          .show(passwordError, type: ToastType.error);
      return;
    }

    ref
        .read(authStateProvider.notifier)
        .join(inviteCode, password, name, phone.isEmpty ? null : phone);
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

    return PopScope(
      canPop: !authState.isLoading,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
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
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingL),
                    Text(
                      'Apartmana Katıl',
                      textAlign: TextAlign.center,
                      style: AppTypography.h2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingL),
                    TextField(
                      controller: _inviteCodeController,
                      enabled: !authState.isLoading,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Davet Kodu',
                        hintText: 'AP3-B12-X7K9',
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                        errorText: _inviteCodeError,
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isNotEmpty &&
                              !AuthValidators.isValidInviteCode(value)) {
                            _inviteCodeError =
                                'Geçersiz davet kodu formatı (Örn: AP3-B12-X7K9)';
                          } else {
                            _inviteCodeError = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    TextField(
                      controller: _nameController,
                      enabled: !authState.isLoading,
                      decoration: InputDecoration(
                        labelText: 'Ad Soyad',
                        hintText: 'Örn: Furkan Kaya',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    TextField(
                      controller: _phoneController,
                      enabled: !authState.isLoading,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: 'Telefon (Opsiyonel)',
                        hintText: '5XX XXX XXXX',
                        prefixText: '+90 ',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        counterText: '',
                        errorText: _phoneError,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          if (value.isNotEmpty &&
                              !AuthValidators.isValidPhone(value)) {
                            _phoneError =
                                'Geçerli bir telefon numarası giriniz';
                          } else {
                            _phoneError = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    PasswordField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      enabled: !authState.isLoading,
                      onChanged: (value) {
                        setState(() {
                          _hasMinLength = value.length >= 8;
                          _hasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
                          _hasLowerCase = RegExp(r'[a-z]').hasMatch(value);
                          _hasNumber = RegExp(r'\d').hasMatch(value);
                          _hasSpecialChar = RegExp(r'[@$!%*?&]').hasMatch(value);
                        });
                      },
                      focusNode: _passwordFocusNode,
                      passwordCriteria: _passwordFocusNode.hasFocus
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCriterion(
                                  'En az 8 karakter',
                                  _hasMinLength,
                                ),
                                _buildCriterion(
                                  'En az 1 büyük harf',
                                  _hasUpperCase,
                                ),
                                _buildCriterion(
                                  'En az 1 küçük harf',
                                  _hasLowerCase,
                                ),
                                _buildCriterion('En az 1 rakam', _hasNumber),
                                _buildCriterion(
                                  'En az 1 özel karakter (@\$!%*?&)',
                                  _hasSpecialChar,
                                ),
                              ],
                            )
                          : null,
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    PasswordField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                      labelText: 'Şifre Tekrar',
                      enabled: !authState.isLoading,
                      onChanged: (value) {
                        setState(() {
                          _passwordsMatch = value == _passwordController.text;
                        });
                      },
                      helperText: _confirmPasswordController.text.isEmpty
                          ? null
                          : _passwordsMatch
                          ? null
                          : 'Şifreler eşleşmiyor',
                    ),
                    const SizedBox(height: AppSizes.spacingL),
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleJoin,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Katıl'),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    AltActionButton(
                      icon: Icons.person_add_outlined,
                      title: 'Yönetici misiniz? Kaydolun',
                      onTap: authState.isLoading
                          ? null
                          : () => context.push('/register'),
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
              Positioned(
                top: AppSizes.spacingM,
                left: AppSizes.spacingM,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: authState.isLoading ? null : () => context.pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
