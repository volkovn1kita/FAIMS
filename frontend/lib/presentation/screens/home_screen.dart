import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/dashboard_overview.dart';
import 'package:frontend/domain/repositories/dashboard_repository.dart';
import 'package:frontend/domain/repositories/auth_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/analytics_screen.dart';
import 'package:frontend/presentation/screens/manage_departments_screen.dart';
import 'package:frontend/presentation/screens/manage_users_screen.dart';
import 'package:frontend/presentation/screens/manage_kits_screen.dart';
import 'package:frontend/presentation/screens/my_profile_screen.dart';
import 'package:frontend/presentation/screens/settings_screen.dart';
import 'package:frontend/presentation/screens/reports_screen.dart';
import 'package:frontend/core/app_theme.dart';
import 'package:frontend/presentation/widgets/skeleton_loader.dart';
import 'package:go_router/go_router.dart';

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
    }
    
    if (mounted) {
      setState(() {
        _isOverviewLoading = false;
      });
    }
  }

  void _onItemTapped(int index) async {
    if (index == _selectedIndex && index != 1) return;

    if (index == 0) {
      setState(() => _selectedIndex = index);
      _loadOverviewData();
    } else if (index == 1) {
      _openProfile();
    }
  }

  Future<void> _openProfile() async {
    final updatedName = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const MyProfileScreen()),
    );

    if (mounted) {
      if (updatedName != null) {
        setState(() => _userName = updatedName);
      }
      setState(() => _selectedIndex = 0);
      _loadOverviewData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isWeb = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: isWeb
            ? const SizedBox.shrink()
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.black87),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        title: Text(
          'FAIMS',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isWeb ? null : Drawer(child: _buildSideMenu(l10n, isWeb)),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWeb)
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(2, 0))
                ],
              ),
              child: _buildSideMenu(l10n, isWeb),
            ),
          Expanded(
            child: _buildMainContent(l10n, isWeb),
          ),
        ],
      ),
      bottomNavigationBar: isWeb
          ? null
          : Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5)),
                ],
              ),
              child: BottomNavigationBar(
                elevation: 0,
                backgroundColor: Colors.white,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: const Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.home_rounded, size: 26)),
                    label: l10n.home,
                  ),
                  BottomNavigationBarItem(
                    icon: const Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.person_outline_rounded, size: 26)),
                    label: l10n.profile,
                  ),
                ],
                currentIndex: 0,
                selectedItemColor: AppTheme.primary,
                unselectedItemColor: Colors.grey.shade400,
                selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                type: BottomNavigationBarType.fixed,
                onTap: _onItemTapped,
              ),
            ),
    );
  }

  Widget _buildSideMenu(AppLocalizations l10n, bool isWeb) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 40, bottom: 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryLight, AppTheme.primaryDark],
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
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.faimsMenu,
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1.5),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            children: [
              if (widget.userRole == 'Administrator') ...[
                _buildDrawerItem(
                  icon: Icons.bar_chart_rounded,
                  title: l10n.analytics,
                  onTap: () {
                    if (!isWeb) Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AnalyticsScreen()));
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long_rounded,
                  title: l10n.reportsAndLists,
                  onTap: () {
                    if (!isWeb) Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReportsScreen()));
                  },
                ),
              ],
              if (isWeb)
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: l10n.profile,
                  onTap: _openProfile,
                ),
              _buildDrawerItem(
                icon: Icons.settings_outlined,
                title: l10n.settings,
                onTap: () {
                  if (!isWeb) Navigator.pop(context);
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
                onTap: () async {
                  await AuthRepository().logout();
                  if (!mounted) return;
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(AppLocalizations l10n, bool isWeb) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 40.0 : 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.welcomeUser(_userName),
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_outlined, size: 16, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(
                  widget.userRole,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            l10n.overview,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isOverviewLoading
                  ? GridView.count(
                      key: const ValueKey('skeleton'),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWeb ? 4 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isWeb ? 1.0 : 0.85,
                      children: List.generate(
                        4,
                        (_) => SkeletonLoader(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 24,
                        ),
                      ),
                    )
                  : _overviewError.isNotEmpty
                      ? Center(
                          key: const ValueKey('error'),
                          child: Text(_overviewError, style: const TextStyle(color: Colors.red)),
                        )
                      : GridView.count(
                          key: const ValueKey('grid'),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: isWeb ? 4 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isWeb ? 1.0 : 0.85,
                          children: [
                            _buildDashboardCard(
                              title: l10n.manageKits,
                              value: _overviewData!.totalKits.toString(),
                              icon: Icons.inventory_2_outlined,
                              color: AppTheme.primary,
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
            ),
        ],
      ),
    );
  }

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
                  style: TextStyle(
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
    return _HoverDashboardCard(
      color: color,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.black87, height: 1.0),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600, height: 1.2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HoverDashboardCard extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  const _HoverDashboardCard({
    required this.color,
    required this.onTap,
    required this.child,
  });

  @override
  State<_HoverDashboardCard> createState() => _HoverDashboardCardState();
}

class _HoverDashboardCardState extends State<_HoverDashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _isHovered ? 0.18 : 0.08),
              blurRadius: _isHovered ? 24 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            splashColor: AppTheme.primary.withValues(alpha: 0.08),
            highlightColor: AppTheme.primary.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}