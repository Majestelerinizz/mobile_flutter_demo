import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';

final secureStorageProvider = Provider((ref) => SecureStorage());

final dioClientProvider = Provider((ref) {
  return DioClient(secureStorage: ref.watch(secureStorageProvider));
});

final authRemoteDataSourceProvider = Provider((ref) {
  return AuthRemoteDataSourceImpl(dioClient: ref.watch(dioClientProvider));
});

final authRepositoryProvider = Provider((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(secureStorageProvider),
  );
});

class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? error,
    bool? isAuthenticated,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final SecureStorage _secureStorage;
  final _random = Random();

  AuthNotifier(this._authRepository, this._secureStorage) : super(AuthState());

  /// Random test kullanıcı ismi üretir
  String _generateRandomName() {
    final names = [
      'Ahmet Yılmaz',
      'Mehmet Öztürk',
      'Ayşe Kaya',
      'Fatma Demir',
      'Ali Veli',
      'Zeynep Aydın',
      'Hasan Çelik',
      'Elif Şahin',
      'Mustafa Kocaman',
      'Gülşen Özkan',
      'Hüseyin Polat',
      'Selin Arslan',
    ];
    return names[_random.nextInt(names.length)];
  }

  /// Random test telefon numarası üretir
  String _generateRandomPhone() {
    return '+90555${(_random.nextInt(900000) + 100000)}';
  }

  /// Random kullanıcı ID üretir
  String _generateRandomId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(1000).toString();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Replace this mock service with real backend API when ready
      await Future.delayed(const Duration(seconds: 2));

      // Determine role based on email for demo purposes
      final role = email.contains('manager')
          ? UserRole.manager
          : UserRole.resident;

      final mockUser = UserEntity(
        id: _generateRandomId(),
        email: email,
        name: _generateRandomName(),
        phone: _generateRandomPhone(),
        role: role,
        language: 'tr',
      );

      // Save mock token and expiry for session management
      await _secureStorage.saveToken('mock_token_${mockUser.id}');
      // Token expiry: 15 minutes (Aşama 0 güvenlik standardı)
      await _secureStorage.saveTokenExpiry(
        DateTime.now().add(const Duration(minutes: 15)),
      );

      state = state.copyWith(
        isLoading: false,
        user: mockUser,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String? phone,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.register(email, password, name, phone);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> join(
    String inviteCode,
    String password,
    String name,
    String? phone,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.join(
        inviteCode,
        password,
        name,
        phone,
      );
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.logout();
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
