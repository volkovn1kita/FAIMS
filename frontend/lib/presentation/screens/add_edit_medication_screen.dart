// lib/presentation/screens/add_edit_medication_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:frontend/data/dtos/medication_create_dto.dart';
import 'package:frontend/data/dtos/medication_update_dto.dart';
import 'package:frontend/data/dtos/measurement_unit.dart';
import 'package:frontend/domain/repositories/first_aid_kit_repository.dart';
import 'package:frontend/core/extensions.dart';

class AddEditMedicationScreen extends StatefulWidget {
  final String kitId;
  final String? medicationId;

  const AddEditMedicationScreen({
    super.key,
    required this.kitId,
    this.medicationId,
  });

  @override
  State<AddEditMedicationScreen> createState() => _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = FirstAidKitRepository();

  bool _isLoading = false;
  String _errorMessage = '';

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _minQuantityController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();

  MeasurementUnit? _selectedUnit;
  DateTime? _selectedExpirationDate;

  bool get _isEditing => widget.medicationId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadMedicationDetails();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minQuantityController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicationDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final medication = await _repository.getMedicationById(widget.medicationId!);
      _nameController.text = medication.name;
      _quantityController.text = medication.quantity.toString();
      _minQuantityController.text = medication.minimumQuantity.toString();
      _selectedUnit = medication.unit;
      _selectedExpirationDate = medication.expirationDate.toLocal(); // Перетворення в локальний час для відображення
      _expirationDateController.text = DateFormat('dd.MM.yyyy').format(_selectedExpirationDate!);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Error loading medication details: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    // Якщо дата існує і вона у минулому, то дозволяємо вибирати з минулого.
    // Інакше, перша можлива дата - сьогодні.
    final DateTime firstPossibleDate = (_selectedExpirationDate != null && _selectedExpirationDate!.isBefore(now))
        ? DateTime(2000) // Дозволяємо вибирати з минулого, якщо вже є прострочена
        : now;

    final DateTime initial = _selectedExpirationDate ?? now.add(const Duration(days: 30));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstPossibleDate, // Динамічно встановлюємо firstDate
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 173, 128, 245), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black87, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 173, 128, 245), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedExpirationDate) {
      setState(() {
        // Зберігаємо дату як UTC, але для контролера відображаємо локальну
        _selectedExpirationDate = DateTime.utc(picked.year, picked.month, picked.day);
        _expirationDateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUnit == null) {
      setState(() {
        _errorMessage = 'Please select a measurement unit.';
      });
      return;
    }

    if (_selectedExpirationDate == null) {
      setState(() {
        _errorMessage = 'Please select an expiration date.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // _selectedExpirationDate вже зберігається як UTC в _selectDate
      final DateTime expirationDateUtc = _selectedExpirationDate!.toUtc();

      if (_isEditing) {
        final medicationDto = MedicationUpdateDto(
          id: widget.medicationId!,
          firstAidKitId: widget.kitId,
          name: _nameController.text, // Додано
          quantity: int.parse(_quantityController.text),
          minimumQuantity: int.parse(_minQuantityController.text),
          unit: _selectedUnit!, // Додано
          expirationDate: expirationDateUtc,
        );
        await _repository.updateMedication(medicationDto);
      } else {
        final medicationDto = MedicationCreateDto(
          firstAidKitId: widget.kitId,
          name: _nameController.text,
          quantity: int.parse(_quantityController.text),
          minimumQuantity: int.parse(_minQuantityController.text),
          unit: _selectedUnit!,
          expirationDate: expirationDateUtc,
        );
        await _repository.addMedication(medicationDto);
      }
      Navigator.of(context).pop(true); // Indicate success
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Error saving medication: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          _isEditing ? l10n.editMedication : l10n.addMedication,
          style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(false), // Indicate no change or cancellation
        ),
      ),
      body: _isLoading && _isEditing // Показуємо індикатор завантаження лише при редагуванні, коли деталі завантажуються
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage,
                          style: GoogleFonts.notoSans(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    TextFormField(
                      controller: _nameController,
                      // Тепер дозволено редагування імені в режимі редагування для адміна
                      // enabled: !_isEditing, // Цей рядок видаляємо або змінюємо
                      decoration: InputDecoration(
                        labelText: l10n.medicationName,
                        hintText: l10n.medicationCreateHint,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade400)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color.fromARGB(255, 173, 128, 245), width: 2)),
                      ),
                      style: GoogleFonts.notoSans(fontSize: 16),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.enterMedicationName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<MeasurementUnit>(
                      initialValue: _selectedUnit, // Використовуємо value замість initialValue
                      onChanged: (Unit) {
                        // Тепер дозволено редагування одиниці виміру в режимі редагування для адміна
                        // onChanged: _isEditing ? null : (Unit) { // Цей рядок видаляємо або змінюємо
                        setState(() {
                          _selectedUnit = Unit;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: l10n.unit,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade400)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color.fromARGB(255, 173, 128, 245), width: 2)),
                      ),
                      items: MeasurementUnit.values.map((Unit) {
                        return DropdownMenuItem(
                          value: Unit,
                          child: Text(Unit.name.capitalize(), style: GoogleFonts.notoSans(fontSize: 16)),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) { // Валідація однакова для обох режимів
                          return l10n.selectUnit;
                        }
                        return null;
                      },
                      menuMaxHeight: 300,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.quantity,
                        hintText: l10n.selectQuantityHint,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade400)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color.fromARGB(255, 173, 128, 245), width: 2)),
                      ),
                      style: GoogleFonts.notoSans(fontSize: 16),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.enterQuantity;
                        }
                        final int? quantity = int.tryParse(value);
                        if (quantity == null) {
                          return l10n.quantityMustBeANumber;
                        }
                        // Для адміна дозволяємо Quantity = 0 або більше.
                        // Бекенд буде керувати, коли 0 є допустимим (наприклад, для повного списання)
                        if (quantity < 0) {
                          return l10n.quantityCannotBeNegative;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _minQuantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.minimumQuantity,
                        hintText: l10n.selectMinQuantityHint,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade400)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color.fromARGB(255, 173, 128, 245), width: 2)),
                      ),
                      style: GoogleFonts.notoSans(fontSize: 16),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterMinimumQuantity;
                        }
                        final int? minQuantity = int.tryParse(value);
                        if (minQuantity == null || minQuantity < 0) {
                          return l10n.minimumQuantityMustBeANonNegativeNumber;
                        }

                        //final int? quantity = int.tryParse(_quantityController.text);

                        // Для адміна, minQuantity може бути більшою за quantity.
                        // Це може знадобитися, якщо адмін спочатку встановлює мінімум,
                        // а потім додає кількість.
                        // Перевірку "minQuantity не може бути більшою за quantity"
                        // краще залишити на бекенді, якщо вона критична,
                        // або пом'якшити тут, дозволяючи адміну більшу гнучкість.
                        // Я прибрав сувору перевірку для адміна, дозволяючи йому більшу гнучкість.
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _expirationDateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        labelText: l10n.expirationDate,
                        hintText: 'DD.MM.YYYY',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade400)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color.fromARGB(255, 173, 128, 245), width: 2)),
                      ),
                      style: GoogleFonts.notoSans(fontSize: 16),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.selectExpirationDate;
                        }
                        // Для адміна дозволяємо вибір дати у минулому при редагуванні
                        // (наприклад, якщо медикамент вже прострочений і адмін це фіксує)
                        // При додаванні нового медикаменту, дата повинна бути у майбутньому
                        if (!_isEditing && _selectedExpirationDate != null && _selectedExpirationDate!.isBefore(DateTime.now().toUtc())) {
                          return l10n.expirationDateCannotBeInThePastForNewMedications;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveMedication,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: const Color.fromARGB(255, 173, 128, 245),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _isEditing ? l10n.saveChanges : l10n.addMedication,
                                style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}