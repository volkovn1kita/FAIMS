// lib/presentation/screens/user_home_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/first_aid_kit_list_dto.dart';
import 'package:frontend/data/dtos/medication_dto.dart';
import 'package:frontend/data/dtos/medication_create_dto.dart';
import 'package:frontend/data/dtos/medication_quantity_update_dto.dart';
import 'package:frontend/data/dtos/medication_write_off_dto.dart';
import 'package:frontend/domain/repositories/first_aid_kit_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/my_profile_screen.dart';
import 'package:frontend/core/extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:frontend/data/dtos/expiration_status.dart';
import 'package:frontend/data/dtos/measurement_unit.dart';

// === 1. ІМПОРТИ ЛОКАЛІЗАЦІЇ ===
import 'package:frontend/presentation/screens/settings_screen.dart'; 
// =============================

class UserHomeScreen extends StatefulWidget {
  final String userName;

  const UserHomeScreen({super.key, required this.userName});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;
  final _kitRepository = FirstAidKitRepository();

  FirstAidKitListDto? _myKit;
  List<MedicationDto> _medications = []; // === Оригінальний список з сервера ===
  bool _isLoading = true;
  String _errorMessage = '';
  late String _userName;

  // === НОВІ ЗМІННІ СТАНУ ДЛЯ ФІЛЬТРАЦІЇ ===
  List<MedicationDto> _filteredMedications = []; // Список для відображення
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<ExpirationStatus> _statusFilters = {};
  bool _filterLowStock = false;
  // ==========================================

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _searchController.addListener(_onSearchChanged); // === НОВЕ ===
    _loadMyKitAndMedications();
  }

  // === НОВЕ ===
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // === НОВЕ ===
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  // === НОВИЙ МЕТОД ДЛЯ ФІЛЬТРАЦІЇ ===
  void _applyFilters() {
    List<MedicationDto> filtered = List.from(_medications);

    // 1. Фільтр за назвою
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((m) =>
              m.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // 2. Фільтр за статусом (Expired, Critical)
    if (_statusFilters.isNotEmpty) {
      filtered =
          filtered.where((m) => _statusFilters.contains(m.status)).toList();
    }

    // 3. Фільтр за низьким залишком
    if (_filterLowStock) {
      filtered =
          filtered.where((m) => m.quantity < m.minimumQuantity).toList();
    }

    setState(() {
      _filteredMedications = filtered;
    });
  }

  Future<void> _loadMyKitAndMedications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final kit = await _kitRepository.getMyKit();
      final medications = await _kitRepository.getMedicationsForKit(kit.id);

      if (!mounted) return;
      setState(() {
        _myKit = kit;
        _medications = medications;
        _medications
            .sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
        _applyFilters(); // === ОНОВЛЕННЯ: Застосовуємо фільтри після завантаження
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Error loading your kit: ${e.toString()}';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) async {
    if (index == _selectedIndex && index != 1) return;

    if (index == 0) {
      setState(() => _selectedIndex = index);
      // Не перезавантажуємо, якщо вже на екрані
    } else if (index == 1) {
      final updatedName = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (context) => const MyProfileScreen()),
      );

      if (!mounted) return;
      if (updatedName != null) {
        setState(() => _userName = updatedName);
      }
      // Залишаємось на головному екрані (індекс 0) після повернення з профілю
      setState(() => _selectedIndex = 0);
      // Перезавантажуємо дані, оскільки користувач міг змінити ім'я
      await _loadMyKitAndMedications();
    }
  }

  // ============ ОНОВЛЕНІ ДІАЛОГИ ============

  // === 2. ОНОВЛЕННЯ: Додаємо l10n як параметр ===
  InputDecoration _buildDialogInputDecoration(AppLocalizations l10n, String label, {String? suffixText, String? hintText}) {
    return InputDecoration(
      labelText: label, // <--- label тепер буде перекладеним
      hintText: hintText, // <--- hintText тепер буде перекладеним
      suffixText: suffixText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color.fromARGB(255, 173, 128, 245), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // === 2. ОНОВЛЕННЯ: Додаємо l10n як параметр ===
  Future<void> _showUseMedicationDialog(MedicationDto medication, AppLocalizations l10n) async {
    final quantityController = TextEditingController(text: '1');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.medication, color: Color.fromARGB(255, 173, 128, 245)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.useMedicationTitle(medication.name), // <--- ЗМІНЕНО
                style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.available}: ${medication.quantity} ${medication.unit.name.capitalize()}', // <--- ЗМІНЕНО
              style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: _buildDialogInputDecoration(
                l10n,
                l10n.quantityToUse, // <--- ЗМІНЕНО
                suffixText: medication.unit.name.capitalize(),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.notoSans(color: Colors.grey.shade700)), // <--- ЗМІНЕНО
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 173, 128, 245),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n.use, style: GoogleFonts.notoSans()), // <--- ЗМІНЕНО
          ),
        ],
      ),
    );

    if (result == true) {
      final quantity = int.tryParse(quantityController.text) ?? 0;
      if (quantity <= 0) {
        _showErrorSnackBar(l10n.enterValidQuantity); // <--- ЗМІНЕНО
        return;
      }
      if (quantity > medication.quantity) {
        _showErrorSnackBar(l10n.notEnoughAvailable); // <--- ЗМІНЕНО
        return;
      }
      await _performUseMedication(medication.id, quantity, l10n); // <--- ЗМІНЕНО
    }
  }

  Future<void> _performUseMedication(String medicationId, int quantity, AppLocalizations l10n) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final dto = MedicationQuantityUpdateDto(quantity: quantity);
      await _kitRepository.useMedication(medicationId, dto);
      
      if (!mounted) return;
      _showSuccessSnackBar(l10n.medicationUsedSuccess); // <--- ЗМІНЕНО
      await _loadMyKitAndMedications();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Error using medication: ${e.toString()}';
      });
      _showErrorSnackBar(_errorMessage);
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // === 2. ОНОВЛЕННЯ: Додаємо l10n як параметр ===
  Future<void> _showWriteOffDialog(MedicationDto medication, AppLocalizations l10n) async {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.writeOffMedicationTitle(medication.name), // <--- ЗМІНЕНО
                style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.available}: ${medication.quantity} ${medication.unit.name.capitalize()}', // <--- ЗМІНЕНО
                style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: _buildDialogInputDecoration(
                  l10n,
                  l10n.quantityToWriteOff, // <--- ЗМІНЕНО
                  suffixText: medication.unit.name.capitalize(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: _buildDialogInputDecoration(
                  l10n,
                  l10n.reasonRequired, // <--- ЗМІНЕНО
                  hintText: l10n.reasonHint, // <--- ЗМІНЕНО
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.notoSans(color: Colors.grey.shade700)), // <--- ЗМІНЕНО
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n.writeOff, style: GoogleFonts.notoSans()), // <--- ЗМІНЕНО
          ),
        ],
      ),
    );

    if (result == true) {
      final quantity = int.tryParse(quantityController.text) ?? 0;
      final reason = reasonController.text.trim();

      if (quantity <= 0) {
        _showErrorSnackBar(l10n.enterValidQuantity); // <--- ЗМІНЕНО
        return;
      }
      if (reason.isEmpty) {
        _showErrorSnackBar(l10n.reasonIsRequired); // <--- ЗМІНЕНО
        return;
      }
      if (quantity > medication.quantity) {
        _showErrorSnackBar(l10n.notEnoughAvailable); // <--- ЗМІНЕНО
        return;
      }
      await _performWriteOff(medication.id, quantity, reason, l10n); // <--- ЗМІНЕНО
    }
  }

  Future<void> _performWriteOff(
      String medicationId, int quantity, String reason, AppLocalizations l10n) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final dto = MedicationWriteOffDto(quantity: quantity, reason: reason);
      await _kitRepository.writeOffMedication(medicationId, dto);
      
      if (!mounted) return;
      _showSuccessSnackBar(l10n.medicationWrittenOffSuccess); // <--- ЗМІНЕНО
      await _loadMyKitAndMedications();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Error writing off medication: ${e.toString()}';
      });
      _showErrorSnackBar(_errorMessage);
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // === 2. ОНОВЛЕННЯ: Додаємо l10n як параметр ===
  Future<void> _showAddMedicationDialog(AppLocalizations l10n) async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final minQuantityController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 365));
    MeasurementUnit selectedUnit = MeasurementUnit.pieces;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.add_circle, color: Color.fromARGB(255, 173, 128, 245)),
              const SizedBox(width: 10),
              Text(
                l10n.addNewMedication, // <--- ЗМІНЕНО
                style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: _buildDialogInputDecoration(l10n, l10n.medicationName), // <--- ЗМІНЕНО
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: _buildDialogInputDecoration(l10n, l10n.quantity), // <--- ЗМІНЕНО
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: minQuantityController,
                  keyboardType: TextInputType.number,
                  decoration: _buildDialogInputDecoration(l10n, l10n.minimumQuantity), // <--- ЗМІНЕНО
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<MeasurementUnit>(
                  initialValue: selectedUnit,
                  decoration: _buildDialogInputDecoration(l10n, l10n.unit), // <--- ЗМІНЕНО
                  items: MeasurementUnit.values.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit.name.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedUnit = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300)
                  ),
                  title: Text(l10n.expirationDate, style: GoogleFonts.notoSans(fontSize: 14)), // <--- ЗМІНЕНО
                  subtitle: Text(DateFormat('dd.MM.yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(l10n.cancel, style: GoogleFonts.notoSans(color: Colors.grey.shade700)), // <--- ЗМІНЕНО
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'quantity': quantityController.text,
                  'minQuantity': minQuantityController.text,
                  'unit': selectedUnit,
                  'expirationDate': selectedDate,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 173, 128, 245),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(l10n.add, style: GoogleFonts.notoSans()), // <--- ЗМІНЕНО
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final name = result['name'] as String;
      final quantity = int.tryParse(result['quantity'] as String) ?? 0;
      final minQuantity = int.tryParse(result['minQuantity'] as String) ?? 0;
      final unit = result['unit'] as MeasurementUnit;
      final expirationDate = result['expirationDate'] as DateTime;

      if (name.trim().isEmpty) {
        _showErrorSnackBar(l10n.enterMedicationName); // <--- ЗМІНЕНО
        return;
      }
      if (quantity <= 0) {
        _showErrorSnackBar(l10n.enterValidQuantity); // <--- ЗМІНЕНО
        return;
      }

      await _performAddMedication(
          name, quantity, minQuantity, unit, expirationDate, l10n); // <--- ЗМІНЕНО
    }
  }

  Future<void> _performAddMedication(
      String name,
      int quantity,
      int minQuantity,
      MeasurementUnit unit,
      DateTime expirationDate,
      AppLocalizations l10n) async { // <--- ЗМІНЕНО
    if (_myKit == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final utcExpirationDate = DateTime.utc(
        expirationDate.year,
        expirationDate.month,
        expirationDate.day,
        23,
        59,
        59,
      );

      final dto = MedicationCreateDto(
        firstAidKitId: _myKit!.id,
        name: name,
        quantity: quantity,
        minimumQuantity: minQuantity,
        unit: unit,
        expirationDate: utcExpirationDate,
      );
      await _kitRepository.addMedication(dto);
      
      if (!mounted) return;
      _showSuccessSnackBar(l10n.medicationAddedSuccess); // <--- ЗМІНЕНО
      await _loadMyKitAndMedications();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Error adding medication: ${e.toString()}';
      });
      _showErrorSnackBar(_errorMessage);
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.notoSans()), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.notoSans()), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    // === 3. ОТРИМУЄМО ДОСТУП ДО СЛОВНИКА ===
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          tooltip: l10n.logout, // <--- ЗМІНЕНО
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          },
        ),
        title: Text(
          l10n.myFirstAidKit, // <--- ЗМІНЕНО
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _isLoading ? null : _loadMyKitAndMedications,
          ),
          // === 4. НОВА КНОПКА НАЛАШТУВАНЬ ===
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            tooltip: l10n.settings,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_errorMessage, textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red, fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadMyKitAndMedications,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry), // <--- ЗМІНЕНО
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 173, 128, 245)),
                        ),
                      ],
                    ),
                  ),
                )
              : _myKit == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          l10n.notAssignedToKit, // <--- ЗМІНЕНО
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey.shade700)
                        ),
                      ))
                  : RefreshIndicator(
                      onRefresh: _loadMyKitAndMedications,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      l10n.welcomeUser(_userName), // <--- ЗМІНЕНО (з параметром)
                                      style: GoogleFonts.notoSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    avatar: Icon(
                                      Icons.person,
                                      size: 18,
                                      color: Colors.grey.shade700,
                                    ),
                                    label: Text(
                                      l10n.userRoleUser, // <--- ЗМІНЕНО
                                      style: GoogleFonts.notoSans(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    backgroundColor: Colors.grey.shade200,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                ],
                              ),
                            ),
                            
                            _buildKitInfoCard(),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(l10n.medications, // <--- ЗМІНЕНО
                                    style: GoogleFonts.notoSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87)),
                                Row(
                                  children: [
                                    Text('${_filteredMedications.length} ${l10n.items}', // <--- ЗМІНЕНО
                                        style: GoogleFonts.notoSans(
                                            fontSize: 14,
                                            color: Colors.grey.shade600)),
                                    const SizedBox(width: 8),
                                    // 5. ОНОВЛЕННЯ: Кнопка "Додати" переїхала сюди, щоб не перекривати FAB
                                    ElevatedButton.icon(
                                      onPressed: () => _showAddMedicationDialog(l10n), // <--- ЗМІНЕНО
                                      icon: const Icon(Icons.add, size: 18),
                                      label: Text(l10n.add, style: GoogleFonts.notoSans(fontSize: 13)), // <--- ЗМІНЕНО
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 173, 128, 245),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            _buildFilterSection(),
                            _buildMedicationList(),
                          ],
                        ),
                      ),
                    ),
      // FAB видалено, щоб не перекривати навігацію
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), label: l10n.home), // <--- ЗМІНЕНО
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: l10n.profile), // <--- ЗМІНЕНО
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 173, 128, 245),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildFilterSection() {
    final l10n = AppLocalizations.of(context)!; // Отримуємо l10n тут
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.searchMedicationHint, // <--- ЗМІНЕНО
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color.fromARGB(255, 173, 128, 245), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: Text(l10n.expired, style: GoogleFonts.notoSans()),
                selected: _statusFilters.contains(ExpirationStatus.expired),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _statusFilters.add(ExpirationStatus.expired);
                    } else {
                      _statusFilters.remove(ExpirationStatus.expired);
                    }
                    _applyFilters();
                  });
                },
                selectedColor: Colors.red.shade100,
                checkmarkColor: Colors.red,
              ),
              const SizedBox(width: 8), // Відступ між чіпами
              FilterChip(
                label: Text(l10n.critical, style: GoogleFonts.notoSans()),
                selected: _statusFilters.contains(ExpirationStatus.critical),
                onSelected: (selected) {
                   setState(() {
                    if (selected) {
                      _statusFilters.add(ExpirationStatus.critical);
                    } else {
                      _statusFilters.remove(ExpirationStatus.critical);
                    }
                    _applyFilters();
                  });
                },
                selectedColor: Colors.deepOrange.shade100,
                checkmarkColor: Colors.deepOrange,
              ),
              const SizedBox(width: 8), // Відступ між чіпами
              FilterChip(
                label: Text(l10n.lowStock, style: GoogleFonts.notoSans()),
                selected: _filterLowStock,
                onSelected: (selected) {
                  setState(() {
                    _filterLowStock = selected;
                    _applyFilters();
                  });
                },
                selectedColor: Colors.amber.shade100,
                checkmarkColor: Colors.amber.shade800,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMedicationList() {
    final l10n = AppLocalizations.of(context)!; // Отримуємо l10n тут
    if (_medications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.medication_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(l10n.noMedicationsYet, // <--- ЗМІНЕНО
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text(l10n.tapToAddMedication, // <--- ЗМІНЕНО
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
    }

    if (_filteredMedications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(l10n.noMedicationsFound, // <--- ЗМІНЕНО
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text(l10n.adjustSearchFilters, // <--- ЗМІНЕНО
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredMedications.length,
      itemBuilder: (context, index) {
        return _buildMedicationCard(_filteredMedications[index]);
      },
    );
  }


  Widget _buildKitInfoCard() {
    final l10n = AppLocalizations.of(context)!; // Отримуємо l10n тут
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.grey.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_myKit!.name, style: GoogleFonts.notoSans(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text('ID: ${_myKit!.uniqueNumber}',
                          style: GoogleFonts.notoSans(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                _buildStatusChip(_myKit!.statusBadge),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.business, l10n.department, _myKit!.departmentName), // <--- ЗМІНЕНО
            const SizedBox(height: 8),
            _buildInfoRow(Icons.meeting_room, l10n.room, _myKit!.roomName), // <--- ЗМІНЕНО
            if (_myKit!.expiredItemsCount > 0 || _myKit!.criticalItemsCount > 0 || _myKit!.lowQuantityItemsCount > 0)
              ...[
                const Divider(height: 24),
                _buildWarningRow(),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600)), // Label вже перекладений
        Expanded(child: Text(value, style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey.shade700))),
      ],
    );
  }

  Widget _buildWarningRow() {
    final l10n = AppLocalizations.of(context)!; // Отримуємо l10n тут
    final warnings = <String>[];
    if (_myKit!.expiredItemsCount > 0) warnings.add('${_myKit!.expiredItemsCount} ${l10n.expired}'); // <--- ЗМІНЕНО
    if (_myKit!.criticalItemsCount > 0) warnings.add('${_myKit!.criticalItemsCount} ${l10n.critical}'); // <--- ЗМІНЕНО
    if (_myKit!.lowQuantityItemsCount > 0) warnings.add('${_myKit!.lowQuantityItemsCount} ${l10n.lowStock}'); // <--- ЗМІНЕНО

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(warnings.join(', '),
                style: GoogleFonts.notoSans(fontSize: 13, color: Colors.orange.shade900, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    // 6. ОНОВЛЕННЯ: Теж локалізуємо
    final l10n = AppLocalizations.of(context)!;
    final String statusText;
    final Color color;

    if (status == 'Good') {
      statusText = l10n.statusGood;
      color = Colors.green;
    } else {
      // Припускаємо, що все інше це "Needs Attention"
      statusText = l10n.statusWarning;
      color = Colors.orange;
    }

    return Chip(
      label: Text(statusText, style: GoogleFonts.notoSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildMedicationCard(MedicationDto medication) {
    final l10n = AppLocalizations.of(context)!; // Отримуємо l10n тут
    Color statusColor;
    String statusText;

    switch (medication.status) {
      case ExpirationStatus.expired:
        statusColor = Colors.red.shade600;
        statusText = l10n.expired; // <--- ЗМІНЕНО
        break;
      case ExpirationStatus.critical:
        statusColor = Colors.deepOrange.shade600;
        statusText = l10n.critical; // <--- ЗМІНЕНО
        break;
      case ExpirationStatus.warning:
        statusColor = Colors.amber.shade600;
        statusText = l10n.statusWarning; // <--- ЗМІНЕНО
        break;
      case ExpirationStatus.good:
        statusColor = Colors.green.shade600;
        statusText = l10n.statusGood; // <--- ЗМІНЕНО
        break;
    }

    bool isLowQuantity = medication.quantity < medication.minimumQuantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(medication.name, style: GoogleFonts.notoSans(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
                Chip(
                  label: Text(statusText, style: GoogleFonts.notoSans( // <--- statusText вже перекладено
                      fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.inventory, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text('${l10n.quantity}: ', style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600)), // <--- ЗМІНЕНО
                Text('${medication.quantity} ${medication.unit.name.capitalize()}',
                    style: GoogleFonts.notoSans(fontSize: 14, color: isLowQuantity ? Colors.red : Colors.grey.shade700)),
                if (isLowQuantity)
                  Text(' ${l10n.lowStockWarning}', style: GoogleFonts.notoSans(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)), // <--- ЗМІНЕНО
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.arrow_downward, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text('${l10n.minRequired}: ', style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600)), // <--- ЗМІНЕНО
                Text('${medication.minimumQuantity} ${medication.unit.name.capitalize()}',
                    style: GoogleFonts.notoSans(fontSize: 13, color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text('${l10n.expires}: ', style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600)), // <--- ЗМІНЕНО
                Text(DateFormat('dd.MM.yyyy').format(medication.expirationDate),
                    style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showWriteOffDialog(medication, l10n), // <--- ЗМІНЕНО
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  label: Text(l10n.writeOff, style: GoogleFonts.notoSans(fontSize: 13)), // <--- ЗМІНЕНО
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showUseMedicationDialog(medication, l10n), // <--- ЗМІНЕНО
                  icon: const Icon(Icons.medication, size: 18),
                  label: Text(l10n.use, style: GoogleFonts.notoSans(fontSize: 13)), // <--- ЗМІНЕНО
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 173, 128, 245),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}