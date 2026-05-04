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
import '../../../../shared/widgets/password_field.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _emailError;
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
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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

  void _handleRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final nameError = InputValidators.validateName(name);
    if (nameError != null) {
      ref.read(toastProvider.notifier).show(nameError, type: ToastType.error);
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      ref
          .read(toastProvider.notifier)
          .show('Email ve şifre boş bırakılamaz', type: ToastType.error);
      return;
    }

    final emailError = InputValidators.validateEmail(email);
    if (emailError != null) {
      ref.read(toastProvider.notifier).show(emailError, type: ToastType.error);
      return;
    }

    if (phone.isNotEmpty) {
      final phoneError = InputValidators.validatePhone(phone);
      if (phoneError != null) {
        ref
            .read(toastProvider.notifier)
            .show(phoneError, type: ToastType.error);
        return;
      }
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
        .register(email, password, name, phone.isEmpty ? null : phone);
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
                      'Yeni Hesap Oluştur',
                      textAlign: TextAlign.center,
                      style: AppTypography.h2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingL),
                    TextField(
                      controller: _nameController,
                      enabled: !authState.isLoading,
                      style: AppTypography.body1,
                      decoration: InputDecoration(
                        labelText: 'Ad Soyad',
                        hintText: 'Örn: Furkan Kaya',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          size: AppSizes.iconSize,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingM,
                          vertical: AppSizes.spacingM,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.inputRadius,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    TextField(
                      controller: _emailController,
                      enabled: !authState.isLoading,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTypography.body1,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'ornek@email.com',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          size: AppSizes.iconSize,
                        ),
                        errorText: _emailError,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingM,
                          vertical: AppSizes.spacingM,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.inputRadius,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _emailError = InputValidators.validateEmail(value);
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    TextField(
                      controller: _phoneController,
                      enabled: !authState.isLoading,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      style: AppTypography.body1,
                      decoration: InputDecoration(
                        labelText: 'Telefon (Opsiyonel)',
                        hintText: '5XX XXX XXXX',
                        prefixText: '+90 ',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          size: AppSizes.iconSize,
                        ),
                        counterText: '',
                        errorText: _phoneError,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingM,
                          vertical: AppSizes.spacingM,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.inputRadius,
                          ),
                        ),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          _phoneError = InputValidators.validatePhone(value);
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
                      onPressed: authState.isLoading ? null : _handleRegister,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Kaydol'),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    AltActionButton(
                      icon: Icons.login_outlined,
                      title: 'Zaten hesabınız var mı? Giriş yapın',
                      onTap: authState.isLoading
                          ? null
                          : () => context.go('/login'),
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
