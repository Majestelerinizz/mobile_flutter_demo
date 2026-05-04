import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../apartments/data/apartments_store.dart';
import '../../data/buildings_store.dart';
import '../../data/cities_data.dart';

class AddBuildingScreen extends ConsumerStatefulWidget {
  const AddBuildingScreen({super.key});

  @override
  ConsumerState<AddBuildingScreen> createState() => _AddBuildingScreenState();
}

class _AddBuildingScreenState extends ConsumerState<AddBuildingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _floorsController = TextEditingController();
  final _apartmentsPerFloorController = TextEditingController();
  final _monthlyDuesController = TextEditingController();

  String? _selectedCity;
  String? _selectedDistrict;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _floorsController.dispose();
    _apartmentsPerFloorController.dispose();
    _monthlyDuesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yeni Bina Ekle'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.spacingL),
            children: [
              _buildSectionTitle('Temel Bilgiler', Icons.info_outline),
              const SizedBox(height: AppSizes.spacingM),
              _buildTextField(
                controller: _nameController,
                label: 'Bina Adı',
                hint: 'Örn: Güneş Apartmanı',
                icon: Icons.apartment,
                required: true,
              ),
              const SizedBox(height: AppSizes.spacingL),

              _buildSectionTitle('Konum', Icons.location_on_outlined),
              const SizedBox(height: AppSizes.spacingM),
              _buildCityPicker(),
              const SizedBox(height: AppSizes.spacingM),
              _buildDistrictPicker(),
              const SizedBox(height: AppSizes.spacingM),
              _buildTextField(
                controller: _addressController,
                label: 'Sokak / Cadde Adresi',
                hint: 'Örn: Bağdat Cad. No: 123',
                icon: Icons.home_outlined,
                required: true,
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.spacingL),

              _buildSectionTitle('Detaylar', Icons.tune),
              const SizedBox(height: AppSizes.spacingM),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _floorsController,
                      label: 'Kat Sayısı',
                      hint: 'Örn: 4',
                      icon: Icons.stairs_outlined,
                      required: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: _buildTextField(
                      controller: _apartmentsPerFloorController,
                      label: 'Kattaki Daire',
                      hint: 'Örn: 2',
                      icon: Icons.door_front_door_outlined,
                      required: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingM),
              _buildTextField(
                controller: _monthlyDuesController,
                label: 'Aylık Aidat (₺)',
                hint: 'Örn: 1000',
                icon: Icons.payments_outlined,
                required: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppSizes.spacingXL),

              SizedBox(
                height: AppSizes.buttonHeightPrimary,
                child: ElevatedButton.icon(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Bina Oluştur',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              SizedBox(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty)
                ? '$label boş bırakılamaz'
                : null
          : null,
    );
  }

  Widget _buildCityPicker() {
    return _buildDropdownField(
      label: 'Şehir *',
      value: _selectedCity,
      hint: 'Şehir seçin',
      icon: Icons.location_city,
      onTap: _showCityPicker,
    );
  }

  Widget _buildDistrictPicker() {
    final hasCity = _selectedCity != null;
    return _buildDropdownField(
      label: 'İlçe *',
      value: _selectedDistrict,
      hint: hasCity ? 'İlçe seçin' : 'Önce şehir seçin',
      icon: Icons.map_outlined,
      enabled: hasCity,
      onTap: hasCity ? _showDistrictPicker : null,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(
              icon,
              color: enabled ? AppColors.primary : AppColors.textDisabled,
            ),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
            ),
            filled: true,
            fillColor: enabled
                ? Colors.white
                : AppColors.background.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
          ),
          child: Text(
            value ?? hint,
            style: AppTypography.body1.copyWith(
              color: value != null
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: value != null ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _showCityPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SearchablePicker(
        title: 'Şehir Seçin',
        items: sortedCityNames,
        selected: _selectedCity,
        onSelected: (city) {
          setState(() {
            _selectedCity = city;
            _selectedDistrict = null; // şehir değiştiğinde ilçe sıfırlanır
          });
        },
      ),
    );
  }

  void _showDistrictPicker() {
    final districts = turkishCities[_selectedCity] ?? const [];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SearchablePicker(
        title: 'İlçe Seçin',
        items: districts,
        selected: _selectedDistrict,
        onSelected: (district) {
          setState(() => _selectedDistrict = district);
        },
      ),
    );
  }

  void _onSubmit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) {
      ref
          .read(toastProvider.notifier)
          .show('Lütfen zorunlu alanları doldurun', type: ToastType.error);
      return;
    }
    if (_selectedCity == null || _selectedDistrict == null) {
      ref
          .read(toastProvider.notifier)
          .show('Şehir ve ilçe seçmelisiniz', type: ToastType.error);
      return;
    }

    final fullAddress =
        '${_addressController.text.trim()}, $_selectedDistrict, $_selectedCity';
    final floors = int.tryParse(_floorsController.text.trim()) ?? 0;
    final apartmentsPerFloor =
        int.tryParse(_apartmentsPerFloorController.text.trim()) ?? 0;
    final totalApartments = floors * apartmentsPerFloor;
    final monthlyDues =
        double.tryParse(_monthlyDuesController.text.trim()) ?? 0;

    if (floors <= 0 || apartmentsPerFloor <= 0) {
      ref
          .read(toastProvider.notifier)
          .show(
            'Kat sayısı ve daire sayısı 0\'dan büyük olmalı',
            type: ToastType.error,
          );
      return;
    }

    final newBuildingId = ref
        .read(buildingsStoreProvider.notifier)
        .addBuilding(
          name: _nameController.text.trim(),
          address: fullAddress,
          totalApartments: totalApartments,
          monthlyDuesPerApartment: monthlyDues,
        );

    // Daireleri otomatik üret (kat × daire/kat)
    ref
        .read(apartmentsStoreProvider.notifier)
        .generateApartmentsForBuilding(
          buildingId: newBuildingId,
          floors: floors,
          apartmentsPerFloor: apartmentsPerFloor,
          monthlyDues: monthlyDues,
        );

    ref
        .read(toastProvider.notifier)
        .show('Bina başarıyla eklendi', type: ToastType.success);
    Navigator.pop(context);
  }
}

/// Aranabilir liste seçici (şehir veya ilçe için)
class _SearchablePicker extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _SearchablePicker({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_SearchablePicker> createState() => _SearchablePickerState();
}

class _SearchablePickerState extends State<_SearchablePicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((s) => s.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingL,
              vertical: AppSizes.spacingS,
            ),
            child: Text(
              widget.title,
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingL,
              vertical: AppSizes.spacingS,
            ),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Ara...',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Sonuç bulunamadı',
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      final item = filtered[index];
                      final isSelected = item == widget.selected;
                      return ListTile(
                        title: Text(
                          item,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: AppColors.success)
                            : null,
                        onTap: () {
                          widget.onSelected(item);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
