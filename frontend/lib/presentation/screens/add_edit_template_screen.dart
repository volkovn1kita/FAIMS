import 'package:flutter/material.dart';
import 'package:faims/core/app_theme.dart';
import 'package:faims/data/dtos/kit_template_dto.dart';
import 'package:faims/data/dtos/measurement_unit.dart';
import 'package:faims/data/services/kit_template_api_service.dart';
import 'package:faims/l10n/app_localizations.dart';

class AddEditTemplateScreen extends StatefulWidget {
  final KitTemplateDto? template; // null = створення, non-null = редагування

  const AddEditTemplateScreen({super.key, this.template});

  @override
  State<AddEditTemplateScreen> createState() => _AddEditTemplateScreenState();
}

class _AddEditTemplateScreenState extends State<AddEditTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final KitTemplateApiService _service = KitTemplateApiService();

  // Список позицій що редагуються
  final List<_ItemEntry> _items = [];
  bool _isSaving = false;

  bool get isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.template!.name;
      _descController.text = widget.template!.description ?? '';
      for (final item in widget.template!.items) {
        _items.add(_ItemEntry(
          nameController: TextEditingController(text: item.name),
          quantityController: TextEditingController(text: item.minimumQuantity.toString()),
          unit: item.unit,
        ));
      }
    } else {
      // Починаємо з однієї порожньої позиції
      _addItem();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    for (final e in _items) {
      e.nameController.dispose();
      e.quantityController.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(_ItemEntry(
        nameController: TextEditingController(),
        quantityController: TextEditingController(text: '1'),
        unit: MeasurementUnit.pieces,
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].nameController.dispose();
      _items[index].quantityController.dispose();
      _items.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Додайте хоча б один медикамент'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final itemDtos = _items.map((e) => KitTemplateItemDto(
            id: '',
            name: e.nameController.text.trim(),
            minimumQuantity: int.tryParse(e.quantityController.text) ?? 1,
            unit: e.unit,
          )).toList();

      if (isEditing) {
        await _service.updateTemplate(
          id: widget.template!.id,
          name: _nameController.text.trim(),
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          items: itemDtos,
        );
      } else {
        await _service.createTemplate(
          name: _nameController.text.trim(),
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          items: itemDtos,
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? l10n.editTemplate : l10n.addTemplate,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else
            TextButton(
              onPressed: _save,
              child: Text(l10n.save, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Назва шаблону
            _buildCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.templateName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration(l10n.templateNameHint, theme),
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.templateDescription, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descController,
                    decoration: _inputDecoration(l10n.templateDescriptionHint, theme),
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Список медикаментів
            Row(
              children: [
                Icon(Icons.medication_rounded, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(l10n.templateItems, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${_items.length}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),

            ..._items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return _buildItemCard(idx, item, isDark, theme, l10n);
            }),

            // Кнопка + додати медикамент
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: OutlinedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addMedication),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int idx, _ItemEntry item, bool isDark, ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Center(child: Text('${idx + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary))),
              ),
              const Spacer(),
              if (_items.length > 1)
                GestureDetector(
                  onTap: () => _removeItem(idx),
                  child: Icon(Icons.close, size: 18, color: theme.colorScheme.onSurfaceVariant),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: item.nameController,
            decoration: _inputDecoration(l10n.medicationName, theme),
            validator: (v) => (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: item.quantityController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(l10n.minimumQuantity, theme),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return (n == null || n < 1) ? l10n.invalidQuantityError : null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<MeasurementUnit>(
                  value: item.unit,
                  decoration: _inputDecoration(l10n.unit, theme),
                  dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                  items: MeasurementUnit.values.map((u) => DropdownMenuItem(
                    value: u,
                    child: Text(u.localizedName(context), style: const TextStyle(fontSize: 13)),
                  )).toList(),
                  onChanged: (u) => setState(() => item.unit = u ?? item.unit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, required bool isDark}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String hint, ThemeData theme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 13),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

class _ItemEntry {
  TextEditingController nameController;
  TextEditingController quantityController;
  MeasurementUnit unit;

  _ItemEntry({
    required this.nameController,
    required this.quantityController,
    required this.unit,
  });
}
