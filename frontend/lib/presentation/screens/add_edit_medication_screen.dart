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
  bool _isSaving = false; // Додано окремий стейт для кнопки збереження
  String _errorMessage = '';

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
      if (!mounted) return;
      setState(() {
        _nameController.text = medication.name;
        _quantityController.text = medication.quantity.toString();
        _minQuantityController.text = medication.minimumQuantity.toString();
        _selectedUnit = medication.unit;
        _selectedExpirationDate = medication.expirationDate.toLocal(); 
        _expirationDateController.text = DateFormat('dd.MM.yyyy').format(_selectedExpirationDate!);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Error loading medication details: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime firstPossibleDate = (_selectedExpirationDate != null && _selectedExpirationDate!.isBefore(now))
        ? DateTime(2000) 
        : now;

    final DateTime initial = _selectedExpirationDate ?? now.add(const Duration(days: 30));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstPossibleDate,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 143, 88, 225), // Наш фірмовий фіолетовий
              onPrimary: Colors.white, 
              onSurface: Colors.black87, 
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 143, 88, 225), 
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedExpirationDate) {
      setState(() {
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
      _isSaving = true;
      _errorMessage = '';
    });

    try {
      final DateTime expirationDateUtc = _selectedExpirationDate!.toUtc();

      if (_isEditing) {
        final medicationDto = MedicationUpdateDto(
          id: widget.medicationId!,
          firstAidKitId: widget.kitId,
          name: _nameController.text,
          quantity: int.parse(_quantityController.text),
          minimumQuantity: int.parse(_minQuantityController.text),
          unit: _selectedUnit!, 
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
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Error saving medication: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? l10n.editMedication : l10n.addMedication,
          style: GoogleFonts.notoSans(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87, letterSpacing: -0.3),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
            ),
          ),
          Expanded(
            child: _isLoading && _isEditing 
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0).copyWith(bottom: 40),
                    child: Column(
                      children: [
                        if (_errorMessage.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded, color: Colors.red.shade400),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: GoogleFonts.notoSans(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  label: l10n.medicationName,
                                  hintText: l10n.medicationCreateHint,
                                  icon: Icons.vaccines_rounded,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return l10n.enterMedicationName;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                
                                _buildDropdown(l10n),
                                const SizedBox(height: 20),
                                
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _quantityController,
                                        label: l10n.quantity,
                                        hintText: '0',
                                        icon: Icons.tag_rounded,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return l10n.enterQuantity;
                                          final int? quantity = int.tryParse(value);
                                          if (quantity == null) return l10n.quantityMustBeANumber;
                                          if (quantity < 0) return l10n.quantityCannotBeNegative;
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _minQuantityController,
                                        label: l10n.minimumQuantity,
                                        hintText: '0',
                                        icon: Icons.scale_rounded,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return l10n.pleaseEnterMinimumQuantity;
                                          final int? minQuantity = int.tryParse(value);
                                          if (minQuantity == null || minQuantity < 0) return l10n.minimumQuantityMustBeANonNegativeNumber;
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                
                                _buildTextField(
                                  controller: _expirationDateController,
                                  label: l10n.expirationDate,
                                  hintText: 'DD.MM.YYYY',
                                  icon: Icons.calendar_month_rounded,
                                  readOnly: true,
                                  onTap: () => _selectDate(context),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return l10n.selectExpirationDate;
                                    if (!_isEditing && _selectedExpirationDate != null && _selectedExpirationDate!.isBefore(DateTime.now().toUtc())) {
                                      return l10n.expirationDateCannotBeInThePastForNewMedications;
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color.fromARGB(255, 163, 108, 245), Color.fromARGB(255, 123, 68, 205)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 143, 88, 225).withOpacity(0.35),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isSaving ? null : _saveMedication,
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(_isEditing ? Icons.save_rounded : Icons.add_rounded, color: Colors.white, size: 22),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isEditing ? l10n.saveChanges : l10n.addMedication,
                                            style: GoogleFonts.notoSans(
                                              fontSize: 16, 
                                              color: Colors.white, 
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          style: GoogleFonts.notoSans(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: Icon(icon, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color.fromARGB(255, 143, 88, 225), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            l10n.unit,
            style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ),
        DropdownButtonFormField<MeasurementUnit>(
          initialValue: _selectedUnit,
          icon: Icon(Icons.expand_more_rounded, color: Colors.grey.shade600),
          style: GoogleFonts.notoSans(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.science_outlined, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color.fromARGB(255, 143, 88, 225), width: 1.5),
            ),
          ),
          items: MeasurementUnit.values.map((unit) {
            return DropdownMenuItem(
              value: unit,
              child: Text(unit.name.capitalize(), style: GoogleFonts.notoSans()),
            );
          }).toList(),
          onChanged: (MeasurementUnit? newValue) {
            setState(() {
              _selectedUnit = newValue;
            });
          },
          validator: (value) => value == null ? l10n.selectUnit : null,
          menuMaxHeight: 300,
        ),
      ],
    );
  }
}