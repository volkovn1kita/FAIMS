import 'package:flutter/material.dart';
import 'package:faims/core/app_theme.dart';
import 'package:faims/l10n/app_localizations.dart';

class HelpGuideScreen extends StatelessWidget {
  const HelpGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final steps = [
      (
        icon: Icons.domain_rounded,
        color: Colors.teal.shade400,
        title: l10n.onboardingStep1,
        description: _stepDesc1(l10n),
      ),
      (
        icon: Icons.meeting_room_rounded,
        color: Colors.blue.shade400,
        title: l10n.onboardingStep2,
        description: _stepDesc2(l10n),
      ),
      (
        icon: Icons.person_add_rounded,
        color: Colors.purple.shade400,
        title: l10n.onboardingStep3,
        description: _stepDesc3(l10n),
      ),
      (
        icon: Icons.inventory_2_rounded,
        color: AppTheme.primary,
        title: l10n.onboardingStep4,
        description: _stepDesc4(l10n),
      ),
    ];

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
          l10n.helpGuideTitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryLight, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.helpGuideTitle,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.helpGuideSubtitle,
                          style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == steps.length - 1;
              return _buildStepCard(
                context: context,
                theme: theme,
                isDark: isDark,
                index: index + 1,
                icon: step.icon,
                color: step.color,
                title: step.title,
                description: step.description,
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }

  String _stepDesc1(AppLocalizations l10n) =>
      'Перейдіть до розділу "Управління відділами" через головне меню. Натисніть "+" та введіть назву відділу (наприклад: Медична служба, Турбінний цех).';

  String _stepDesc2(AppLocalizations l10n) =>
      'Відкрийте створений відділ і натисніть "Додати кімнату". Вкажіть назву приміщення (наприклад: Медпункт №1, Машинний зал).';

  String _stepDesc3(AppLocalizations l10n) =>
      'Перейдіть до "Управління користувачами". Натисніть "+" та заповніть дані співробітника. Роль "Користувач" дозволяє призначати людину відповідальною за аптечку.';

  String _stepDesc4(AppLocalizations l10n) =>
      'Перейдіть до "Управління аптечками". Натисніть "+" та оберіть відділ, кімнату і відповідальну особу. Після створення аптечки — додайте медикаменти через перегляд аптечки.';

  Widget _buildStepCard({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required int index,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.1)],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '$index',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
