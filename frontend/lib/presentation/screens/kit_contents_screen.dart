import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/add_edit_kit_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/data/dtos/first_aid_kit_list_dto.dart';
import 'package:frontend/data/dtos/medication_dto.dart';
import 'package:frontend/domain/repositories/first_aid_kit_repository.dart';
import 'package:intl/intl.dart';
import 'package:frontend/data/dtos/expiration_status.dart';
import 'package:frontend/presentation/screens/add_edit_medication_screen.dart';
import 'package:frontend/core/extensions.dart';

class KitContentsScreen extends StatefulWidget {
  final String kitId;

  const KitContentsScreen({
    super.key,
    required this.kitId,
  });

  @override
  State<KitContentsScreen> createState() => _KitContentsScreenState();
}

class _KitContentsScreenState extends State<KitContentsScreen> {
  FirstAidKitListDto? _kitDetails;
  List<MedicationDto> _medications = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _kitName = '';

  final _kitRepository = FirstAidKitRepository();

  @override
  void initState() {
    super.initState();
    _loadKitDetailsAndContents();
  }

  Future<void> _loadKitDetailsAndContents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final loadedKit = await _kitRepository.getFirstAidKitById(widget.kitId);
      final loadedMedications = await _kitRepository.getMedicationsForKit(widget.kitId);

      setState(() {
        _kitName = loadedKit.name;
        _kitDetails = loadedKit;
        _medications = loadedMedications;
        // Сортуємо медикаменти за терміном придатності (найближчі до закінчення - перші)
        _medications.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Error loading kit details or contents: ${e.toString()}';
        print('Error loading kit details or contents: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAddEditMedication({String? medicationId}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditMedicationScreen(
          kitId: widget.kitId,
          medicationId: medicationId,
        ),
      ),
    );

    if (result == true || result == null) {
      await _loadKitDetailsAndContents();
    }
  }

  Future<void> _navigateToEditKit() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditKitScreen(
          kitId: widget.kitId, // Передаємо ID поточної аптечки
        ),
      ),
    );

    if (result == true) {
      await _loadKitDetailsAndContents();
    }
  }

  Future<void> _confirmDeleteKit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_medications.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotDeleteKit(_kitName), style: GoogleFonts.notoSans()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return; // Перериваємо видалення
    }
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.confirmDeletion, style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
          content: Text(l10n.confirmDeleteFirstAidKit(_kitName), style: GoogleFonts.notoSans()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel, style: GoogleFonts.notoSans(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete, style: GoogleFonts.notoSans(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        await _kitRepository.deleteKit(widget.kitId); // Викликаємо метод видалення
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.firstAidKitDeletedSuccessfully, style: GoogleFonts.notoSans()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Повертаємось на ManageKitsScreen і повідомляємо про оновлення
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Error deleting first aid kit: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage, style: GoogleFonts.notoSans()),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteMedication(String medicationId, String medicationName) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.confirmDeletion, style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
          content: Text(l10n.firstAidKitDeleteAlert(medicationName), style: GoogleFonts.notoSans()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel, style: GoogleFonts.notoSans(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete, style: GoogleFonts.notoSans(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deleteMedication(medicationId);
    }
  }

  Future<void> _deleteMedication(String medicationId) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await _kitRepository.deleteMedication(medicationId, widget.kitId);
      await _loadKitDetailsAndContents(); // Перезавантажуємо список після видалення
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.medicationDeletedSuccessfully, style: GoogleFonts.notoSans()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Error deleting medication: ${e.toString()}';
        print('Error deleting medication: $e');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage, style: GoogleFonts.notoSans()),
          backgroundColor: Colors.red,
        ),
      );
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
      backgroundColor: Colors.grey.shade100, // Світлий фон для контрасту карток
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _kitDetails?.name ?? l10n.kitsContent,
          style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            onPressed: _isLoading ? null : _navigateToEditKit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _isLoading ? null : _confirmDeleteKit,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)))
              : _kitDetails == null
                  ? Center(child: Text(l10n.kitDetailsNotFound, style: GoogleFonts.notoSans()))
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildKitInfoCard(l10n),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.medication,
                                      style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    // Показуємо кількість ліків
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_medications.length}',
                                        style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                        if (_medications.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                l10n.noMedicationsFoundInThisKit,
                                style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey.shade500),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 80),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildMedicationListItem(_medications[index]),
                                childCount: _medications.length,
                              ),
                            ),
                          ),
                      ],
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditMedication(),
        backgroundColor: const Color.fromARGB(255, 143, 88, 225),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // --- ВІДЖЕТИ ДЛЯ СУЧАСНОГО UI ---

  // Компактна і красива картка з інформацією про аптечку
  Widget _buildKitInfoCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.medical_services_outlined, color: Colors.blue.shade400),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _kitDetails!.name,
                      style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'ID: ${_kitDetails!.uniqueNumber}',
                      style: GoogleFonts.notoSans(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1),
          ),
          _buildInfoPill(Icons.domain, _kitDetails!.departmentName),
          const SizedBox(height: 10),
          _buildInfoPill(Icons.meeting_room_outlined, _kitDetails!.roomName),
          const SizedBox(height: 10),
          _buildInfoPill(Icons.person_outline, '${_kitDetails!.responsibleUserFirstName} ${_kitDetails!.responsibleUserLastName}'),
        ],
      ),
    );
  }

  // Маленький рядок з іконкою для деталей аптечки
  Widget _buildInfoPill(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Оновлена картка медикаменту
  Widget _buildMedicationListItem(MedicationDto medication) {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor;
    String statusText;

    switch (medication.status) {
      case ExpirationStatus.expired:
        statusColor = Colors.redAccent;
        statusText = l10n.expired;
        break;
      case ExpirationStatus.critical:
        statusColor = Colors.orangeAccent;
        statusText = l10n.critical;
        break;
      case ExpirationStatus.warning:
        statusColor = Colors.amber.shade600;
        statusText = l10n.statusWarning;
        break;
      case ExpirationStatus.good:
        statusColor = Colors.green;
        statusText = l10n.statusGood;
        break;
    }

    bool isLowQuantity = medication.quantity < medication.minimumQuantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Dismissible(
        key: Key(medication.id),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            if (medication.quantity > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.quantityIsGreaterThan0Erorr(medication.name)),
                  backgroundColor: Colors.red,
                ),
              );
              return false;
            }
            await _confirmDeleteMedication(medication.id, medication.name);
            return false;
          } else if (direction == DismissDirection.startToEnd) {
            await _navigateToAddEditMedication(medicationId: medication.id);
            return false;
          }
          return false;
        },
        background: _buildSwipeBackground(Icons.edit_outlined, Colors.blue.shade400, Alignment.centerLeft),
        secondaryBackground: _buildSwipeBackground(Icons.delete_outline, Colors.redAccent, Alignment.centerRight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
            ],
            // Тонка лінія зліва, яка показує статус
            border: Border(left: BorderSide(color: statusColor, width: 4)),
          ),
          child: InkWell(
            onTap: () => _navigateToAddEditMedication(medicationId: medication.id),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          medication.name,
                          style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Сучасний Soft-Badge для статусу
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: GoogleFonts.notoSans(fontSize: 12, color: statusColor, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Інформація в один рядок
                  Row(
                    children: [
                      // Кількість
                      Icon(Icons.inventory_2_outlined, size: 16, color: isLowQuantity ? Colors.red : Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        '${medication.quantity} ${medication.unit.name.capitalize()}',
                        style: GoogleFonts.notoSans(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600, 
                          color: isLowQuantity ? Colors.red : Colors.black87
                        ),
                      ),
                      if (isLowQuantity) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.error_outline, size: 14, color: Colors.red.shade400),
                      ],
                      
                      const Spacer(),
                      
                      // Дата закінчення
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd.MM.yyyy').format(medication.expirationDate),
                        style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Фон для свайпу
  Widget _buildSwipeBackground(IconData icon, Color color, Alignment alignment) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}