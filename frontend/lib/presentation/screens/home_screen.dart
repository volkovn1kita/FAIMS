import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/dashboard_overview.dart';
import 'package:frontend/domain/repositories/dashboard_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/analytics_screen.dart';
import 'package:frontend/presentation/screens/manage_departments_screen.dart';
import 'package:frontend/presentation/screens/manage_users_screen.dart';
import 'package:frontend/presentation/screens/manage_kits_screen.dart';
import 'package:frontend/presentation/screens/my_profile_screen.dart';
import 'package:frontend/presentation/screens/settings_screen.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade100, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, 
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.black87),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          'FAIMS',
          style: GoogleFonts.notoSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color.fromARGB(255, 143, 88, 225), 
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
            onPressed: () {
              // TODO: Додати логіку для переходу до сповіщень
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      // === ОНОВЛЕНЕ БОКОВЕ МЕНЮ ===
      drawer: Drawer(
        backgroundColor: Colors.white, // Чисто білий фон для меню
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 163, 108, 245), 
                    Color.fromARGB(255, 123, 68, 205)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.faimsMenu,
                    style: GoogleFonts.notoSans(
                      color: Colors.white, 
                      fontSize: 22, 
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                children: [
                  if (widget.userRole == 'Administrator')
                    _buildDrawerItem(
                      icon: Icons.bar_chart_rounded,
                      title: l10n.analytics,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AnalyticsScreen()));
                      },
                    ),
                  
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: l10n.settings,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
                    },
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Colors.grey.shade200, thickness: 1.5),
                  ),
                  
                  _buildDrawerItem(
                    icon: Icons.logout_rounded,
                    title: l10n.logout,
                    textColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // ============================
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Text(
              l10n.welcomeUser(_userName),
              style: GoogleFonts.notoSans(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 143, 88, 225).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  const Icon(Icons.verified_user_outlined, size: 16, color: Color.fromARGB(255, 143, 88, 225)),
                  const SizedBox(width: 6),
                  Text(
                    widget.userRole,
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: const Color.fromARGB(255, 143, 88, 225),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40), 

            Text(
              l10n.overview,
              style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            _isOverviewLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()))
                : _overviewError.isNotEmpty
                    ? Center(child: Text(_overviewError, style: const TextStyle(color: Colors.red)))
                    : GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85, 
                        children: [
                          _buildDashboardCard(
                            title: l10n.manageKits, 
                            value: _overviewData!.totalKits.toString(),
                            icon: Icons.inventory_2_outlined,
                            color: const Color.fromARGB(255, 143, 88, 225), 
                            onTap: () async {
                              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageKitsScreen()));
                              _loadOverviewData();
                            },
                          ),
                          _buildDashboardCard(
                            title: l10n.attention, 
                            value: _overviewData!.kitsNeedingAttention.toString(),
                            icon: Icons.warning_amber_rounded,
                            color: Colors.orangeAccent, 
                            onTap: () async {
                              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageKitsScreen(initialStatusFilter: 'Needs Attention')));
                              _loadOverviewData();
                            },
                          ),
                          _buildDashboardCard(
                            title: l10n.manageUsers,
                            value: _overviewData!.totalUsers.toString(),
                            icon: Icons.group_outlined,
                            color: Colors.blue.shade400,
                            onTap: () async {
                              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageUsersScreen()));
                              _loadOverviewData();
                            },
                          ),
                          _buildDashboardCard(
                            title: l10n.departments,
                            value: _overviewData!.totalDepartments.toString(),
                            icon: Icons.domain_rounded,
                            color: Colors.teal.shade400,
                            onTap: () async {
                              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageDepartmentsScreen()));
                              _loadOverviewData();
                            },
                          ),
                        ],
                      ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home_rounded, size: 26),
              ),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.person_outline_rounded, size: 26),
              ),
              label: l10n.profile,
            ),
          ],
          currentIndex: 0,
          selectedItemColor: const Color.fromARGB(255, 143, 88, 225),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: GoogleFonts.notoSans(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  // --- ВІДЖЕТ ПУНКТУ МЕНЮ ---
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.black87,
    Color iconColor = Colors.black54,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.grey.shade100,
          highlightColor: Colors.grey.shade50,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08), 
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle, 
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: GoogleFonts.notoSans(
                    fontSize: 34, 
                    fontWeight: FontWeight.w800, 
                    color: Colors.black87,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center, 
                  style: GoogleFonts.notoSans(
                    fontSize: 14, 
                    fontWeight: FontWeight.w600, 
                    color: Colors.grey.shade600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}