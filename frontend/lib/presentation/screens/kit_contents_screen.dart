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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          _kitDetails?.name ?? l10n.kitsContent,
          style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(true), // Завжди повертаємо true
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black87),
            onPressed: _isLoading ? null : _navigateToEditKit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black87),
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _kitDetails!.name,
                            style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'ID: ${_kitDetails!.uniqueNumber}',
                            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            '${l10n.department}:',
                            _kitDetails!.departmentName,
                            alignment: CrossAxisAlignment.start,
                          ),
                          _buildDetailRow(
                            '${l10n.room}:',
                            _kitDetails!.roomName,
                            alignment: CrossAxisAlignment.start,
                          ),
                          _buildDetailRow(
                            '${l10n.responsiblePerson}:',
                            '${_kitDetails!.responsibleUserFirstName} ${_kitDetails!.responsibleUserLastName}',
                            alignment: CrossAxisAlignment.center,
                          ),
                          const Divider(height: 32),
                          Text(
                            '${l10n.medication}:',
                            style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 10),
                          _medications.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      l10n.noMedicationsFoundInThisKit,
                                      style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey.shade700),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _medications.length,
                                  itemBuilder: (context, index) {
                                    final medication = _medications[index];
                                    return _buildMedicationListItem(medication);
                                  },
                                ),
                        ],
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditMedication(),
        backgroundColor: const Color.fromARGB(255, 173, 128, 245),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {CrossAxisAlignment alignment = CrossAxisAlignment.start}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: alignment,
        children: [
          SizedBox(
            width: 150,
            child: Text('$label ', style: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value, style: GoogleFonts.notoSans(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationListItem(MedicationDto medication) {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor;
    String statusText;

    switch (medication.status) {
      case ExpirationStatus.expired:
        statusColor = Colors.red.shade600;
        statusText = l10n.expired;
        break;
      case ExpirationStatus.critical:
        statusColor = Colors.deepOrange.shade600;
        statusText = l10n.critical;
        break;
      case ExpirationStatus.warning:
        statusColor = Colors.amber.shade600;
        statusText = l10n.statusWarning;
        break;
      case ExpirationStatus.good:
        statusColor = Colors.green.shade600;
        statusText = l10n.statusGood;
        break;
    }

    bool isLowQuantity = medication.quantity < medication.minimumQuantity;
    Color quantityColor = isLowQuantity ? Colors.red.shade700 : Colors.black87;
    String quantityWarning = isLowQuantity ? ' (${l10n.lowStock}!)' : '';

    return Dismissible(
      key: Key(medication.id),
      direction: DismissDirection.horizontal, // Дозволяємо свайп в обидва боки
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Свайп вліво (видалення)
          if (medication.quantity > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.quantityIsGreaterThan0Erorr(medication.name), style: GoogleFonts.notoSans()),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
            return false;
          }
          await _confirmDeleteMedication(medication.id, medication.name); // Викликаємо діалог підтвердження
          return false; // Не дозволяємо Dismissible видаляти елемент
        } else if (direction == DismissDirection.startToEnd) {
          // Свайп вправо (редагування)
          await _navigateToAddEditMedication(medicationId: medication.id);
          return false; // Не дозволяємо Dismissible видаляти елемент
        }
        return false;
      },
      // Фон для свайпу вправо (редагування)
      background: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0), // Той самий маргін, що і у основного Card
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.blue.shade600, // Колір для редагування
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.edit, color: Colors.white, size: 30),
          ),
        ),
      ),
      // Фон для свайпу вліво (видалення)
      secondaryBackground: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0), // Той самий маргін
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.red.shade700, // Колір для видалення
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white, size: 30),
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            _navigateToAddEditMedication(medicationId: medication.id);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        medication.name,
                        style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Chip(
                      label: Text(
                        statusText,
                        style: GoogleFonts.notoSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: statusColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMedicationInfoRow(
                  Icons.inventory,
                  l10n.quantity,
                  '${medication.quantity} ${medication.unit.name.capitalize()}$quantityWarning', // Капіталізуємо одиницю
                  valueColor: quantityColor,
                ),
                _buildMedicationInfoRow(
                  Icons.calendar_today,
                  '${l10n.expires}:',
                  DateFormat('dd.MM.yyyy').format(medication.expirationDate),
                ),
                _buildMedicationInfoRow(
                  Icons.warning_amber,
                  '${l10n.minimumQuantity}:',
                  '${medication.minimumQuantity} ${medication.unit.name.capitalize()}', // Капіталізуємо одиницю
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationInfoRow(IconData icon, String label, String value, {Color valueColor = Colors.grey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(
            '$label ',
            style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.notoSans(fontSize: 14, color: valueColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}