import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/dashboard_overview.dart';
import 'package:frontend/domain/repositories/dashboard_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/analytics_screen.dart';
import 'package:frontend/presentation/screens/manage_departments_screen.dart';
import 'package:frontend/presentation/screens/manage_users_screen.dart';
import 'package:frontend/presentation/screens/manage_kits_screen.dart';
import 'package:frontend/presentation/screens/my_profile_screen.dart';
import 'package:frontend/presentation/screens/settings_screen.dart'; // 1. ІМПОРТ SETTINGS
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userRole;

  const HomeScreen({super.key, required this.userName, required this.userRole});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final DashboardRepository _dashboardRepository = DashboardRepository();
  DashboardOverview? _overviewData;
  bool _isOverviewLoading = true;
  String _overviewError = '';
  late String _userName;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _loadOverviewData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
      _loadOverviewData(); 
  }

  Future<void> _loadOverviewData() async {
    // ... (без змін) ...
    if (!mounted) return;
    setState(() {
      _isOverviewLoading = true;
      _overviewError = '';
    });

    try {
      final data = await _dashboardRepository.getDashboardOverview();
      if (!mounted) return;
      setState(() {
        _overviewData = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _overviewError = 'Failed to load data: ${e.toString()}';
      });
      print('Error loading dashboard overview: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isOverviewLoading = false;
      });
    }
  }

  void _onItemTapped(int index) async {
    // ... (без змін) ...
    if (index == _selectedIndex && index != 1) {
      return;
    }

    if (index == 0) {
      setState(() {
        _selectedIndex = index;
      });
      _loadOverviewData();
    } else if (index == 1) {
      final updatedName = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (context) => const MyProfileScreen()),
      );

      if (!mounted) return;

      if (updatedName != null) {
        setState(() {
          _userName = updatedName;
        });
      }

      setState(() {
        _selectedIndex = 0;
      });
      _loadOverviewData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. ОТРИМУЄМО ДОСТУП ДО СЛОВНИКА
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // ... (без змін) ...
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          'FAIMS',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.black87),
            onPressed: () {
              // TODO: Додати логіку для переходу до сповіщень
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 173, 128, 245),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: .0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      l10n.faimsMenu, // <--- ЗМІНЕНО
                      style: GoogleFonts.notoSans(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 36,
                    ),
                  ],
                ),
              ),
            ),
            if (widget.userRole == 'Administrator')
              ListTile(
                leading: const Icon(Icons.bar_chart_rounded),
                title: Text(l10n.analytics, style: GoogleFonts.notoSans()), // <--- ЗМІНЕНО
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settings, style: GoogleFonts.notoSans()), // <--- ЗМІНЕНО
              onTap: () {
                Navigator.pop(context);
                // 4. ДОДАЄМО НАВІГАЦІЮ
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            const Divider(thickness: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text(l10n.logout, style: GoogleFonts.notoSans(color: Colors.redAccent)), // <--- ЗМІНЕНО
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // ... (без змін) ...
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.welcomeUser(_userName), // <--- ЗМІНЕНО (з параметром)
                  style: GoogleFonts.notoSans(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: Chip(
                    label: Text(
                      widget.userRole, // Роль можна теж перекласти, якщо додати в .arb
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: const Color.fromARGB(150, 81, 0, 255),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.overview, // <--- ЗМІНЕНО
              style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _isOverviewLoading
                ? const Center(child: CircularProgressIndicator())
                : _overviewError.isNotEmpty
                    ? Center(
                        child: Text(_overviewError, style: const TextStyle(color: Colors.red)),
                      )
                    : GridView.count(
                        // ... (без змін) ...
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          _buildOverviewCard(
                              context, l10n.totalKits, _overviewData!.totalKits.toString(), Icons.inventory_2_outlined), // <--- ЗМІНЕНО
                          _buildOverviewCard(context, l10n.kitsNeedingAttention,
                              _overviewData!.kitsNeedingAttention.toString(), Icons.warning_amber_outlined), // <--- ЗМІНЕНО
                          _buildOverviewCard(context, l10n.users, _overviewData!.totalUsers.toString(), Icons.people_outline), // <--- ЗМІНЕНО
                          _buildOverviewCard(
                              context, l10n.departments, _overviewData!.totalDepartments.toString(), Icons.business_outlined), // <--- ЗМІНЕНО
                        ],
                      ),
            const SizedBox(height: 32),
            Text(
              l10n.shortcuts, // <--- ЗМІНЕНО
              style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GridView.count(
              // ... (без змін) ...
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildShortcutButton(context, l10n.manageKits, Icons.storage,
                    const Color.fromARGB(135, 198, 157, 251), null), // <--- ЗМІНЕНО
                _buildShortcutButton(context, l10n.attention, Icons.error_outline,
                    const Color.fromARGB(135, 198, 157, 251), 'Needs Attention'), // <--- ЗМІНЕНО
                _buildShortcutButton(context, l10n.manageUsers, Icons.group_outlined,
                    const Color.fromARGB(135, 198, 157, 251), null), // <--- ЗМІНЕНО
                _buildShortcutButton(context, l10n.departments, Icons.apartment,
                    const Color.fromARGB(135, 198, 157, 251), null), // <--- ЗМІНЕНО
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: l10n.home, // <--- ЗМІНЕНО
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: l10n.profile, // <--- ЗМІНЕНО
          ),
        ],
        currentIndex: 0,
        selectedItemColor: const Color.fromARGB(255, 173, 128, 245),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, String title, String value, IconData icon) {
    // ... (без змін, тут немає тексту для перекладу, крім title, який ми вже передаємо перекладеним)
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.notoSans(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Icon(icon, color: Colors.grey.shade400, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutButton(
    BuildContext context,
    String label,
    IconData icon,
    Color bgColor,
    String? statusFilter,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return ElevatedButton(
      onPressed: () async {
        if (label == l10n.manageKits) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ManageKitsScreen()),
          );
          _loadOverviewData();
        } else if (label == l10n.attention) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ManageKitsScreen(initialStatusFilter: statusFilter)),
          );
          _loadOverviewData();
        } else if (label == l10n.manageUsers) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
          );
          _loadOverviewData();
        } else if (label == l10n.departments) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ManageDepartmentsScreen()),
          );
          _loadOverviewData();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // <-- Центруємо ВСЕ
        mainAxisSize: MainAxisSize.min,              // <-- Не розтягуємо зайве
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center, // <-- Центруємо ТЕКСТ
              style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

}