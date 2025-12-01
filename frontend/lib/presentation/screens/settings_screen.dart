import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/providers/locale_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    // Отримуємо доступ до словника
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings, // Використовуємо локалізований текст
          style: GoogleFonts.notoSans(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Оберіть мову / Select Language',
              style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Українська', style: GoogleFonts.notoSans()),
              leading: const CircleAvatar(child: Text('🇺🇦')),
              trailing: (localeProvider.locale?.languageCode == 'uk')
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                localeProvider.setLocale(const Locale('uk'));
                // Не закриваємо екран, щоб юзер бачив зміни
              },
            ),
            const Divider(),
            ListTile(
              title: Text('English', style: GoogleFonts.notoSans()),
              leading: const CircleAvatar(child: Text('🇬🇧')),
              trailing: (localeProvider.locale?.languageCode == 'en')
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
              },
            ),
          ],
        ),
      ),
    );
  }
}