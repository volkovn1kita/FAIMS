import 'package:flutter/material.dart';
import 'package:faims/core/app_theme.dart';
import 'package:faims/data/dtos/kit_template_dto.dart';
import 'package:faims/data/services/kit_template_api_service.dart';
import 'package:faims/l10n/app_localizations.dart';
import 'package:faims/presentation/screens/add_edit_template_screen.dart';

class ManageTemplatesScreen extends StatefulWidget {
  const ManageTemplatesScreen({super.key});

  @override
  State<ManageTemplatesScreen> createState() => _ManageTemplatesScreenState();
}

class _ManageTemplatesScreenState extends State<ManageTemplatesScreen> {
  final KitTemplateApiService _service = KitTemplateApiService();
  List<KitTemplateDto> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    try {
      final templates = await _service.getAllTemplates();
      if (mounted) setState(() => _templates = templates);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTemplate(KitTemplateDto template) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text('Видалити шаблон "${template.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _service.deleteTemplate(template.id);
      _loadTemplates();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
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
          l10n.kitTemplates,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
            onPressed: _loadTemplates,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditTemplateScreen()),
          );
          _loadTemplates();
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n.addTemplate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? _buildEmpty(l10n, theme)
              : RefreshIndicator(
                  onRefresh: _loadTemplates,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      // Системні шаблони
                      _buildSectionHeader(l10n.systemTemplates, Icons.verified_rounded, Colors.teal, theme),
                      ..._templates
                          .where((t) => t.isSystem)
                          .map((t) => _buildTemplateCard(t, isDark, theme, l10n)),

                      const SizedBox(height: 16),

                      // Власні шаблони
                      _buildSectionHeader(l10n.customTemplates, Icons.tune_rounded, AppTheme.primary, theme),
                      ..._templates
                          .where((t) => !t.isSystem)
                          .map((t) => _buildTemplateCard(t, isDark, theme, l10n)),

                      if (_templates.where((t) => !t.isSystem).isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 8),
                          child: Text(
                            l10n.noCustomTemplates,
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(KitTemplateDto template, bool isDark, ThemeData theme, AppLocalizations l10n) {
    return Card(
      color: isDark ? AppTheme.darkCard : Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (template.isSystem ? Colors.teal : AppTheme.primary).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            template.isSystem ? Icons.verified_rounded : Icons.tune_rounded,
            color: template.isSystem ? Colors.teal : AppTheme.primary,
            size: 20,
          ),
        ),
        title: Text(template.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.onSurface)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (template.description != null)
              Text(template.description!, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
            if (template.regulatoryReference != null)
              Text(template.regulatoryReference!, style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.w500)),
            Text(
              '${template.items.length} ${l10n.templateItemsCount}',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        trailing: template.isSystem
            ? const Icon(Icons.lock_rounded, size: 16, color: Colors.teal)
            : PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AddEditTemplateScreen(template: template)),
                    );
                    _loadTemplates();
                  } else if (value == 'delete') {
                    await _deleteTemplate(template);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit_rounded, size: 18), const SizedBox(width: 8), Text(l10n.edit)])),
                  PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete_rounded, size: 18, color: Colors.red), const SizedBox(width: 8), Text(l10n.delete, style: const TextStyle(color: Colors.red))])),
                ],
              ),
        children: template.items.map((item) => _buildItemRow(item, theme, l10n)).toList(),
      ),
    );
  }

  Widget _buildItemRow(KitTemplateItemDto item, ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(item.name, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface))),
          Text(
            '${item.minimumQuantity} ${item.unit.localizedName(context)}',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.content_paste_off_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(l10n.noTemplates, style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
