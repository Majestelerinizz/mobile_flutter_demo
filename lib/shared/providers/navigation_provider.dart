import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manager dashboard için tab index state provider
/// TabController ile sync edilir, BottomNavigationBar'ın currentIndex'ini yönetir
final managerTabIndexProvider = StateProvider<int>((ref) => 0);

/// Resident dashboard için tab index state provider
final residentTabIndexProvider = StateProvider<int>((ref) => 0);
