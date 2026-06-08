import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hibah_2026/config/app_config.dart';
import 'package:hibah_2026/models/menu_day_summary_model.dart';
import 'package:hibah_2026/pages/menu_history/menu_day_detail_page.dart';
import 'package:http/http.dart' as http;

class MenuDayListPage extends StatefulWidget {
  const MenuDayListPage({super.key, required this.clientId});

  final String clientId;

  @override
  State<MenuDayListPage> createState() => _MenuDayListPageState();
}

class _MenuDayListPageState extends State<MenuDayListPage> {
  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color background = Color(0xFFF7F7F7);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  bool isLoading = false;
  bool isDeleting = false;
  String? errorMessage;

  int page = 1;
  int limit = 10;
  int totalPages = 1;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  bool selectionMode = false;
  List<MenuDaySummary> menuDays = [];
  final Set<int> selectedIds = {};

  bool get isSelectionMode => selectionMode;

  @override
  void initState() {
    super.initState();
    fetchMenuDays();
  }

  void enterSelectionMode() {
    setState(() {
      selectionMode = true;
      selectedIds.clear();
    });
  }

  void exitSelectionMode() {
    setState(() {
      selectionMode = false;
      selectedIds.clear();
    });
  }

  Future<void> fetchMenuDays({int? targetPage}) async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final selectedPage = targetPage ?? page;

      final response = await http.get(
        AppConfig.apiUri(
          '/api/screening/client/${widget.clientId}/menu-days?page=$selectedPage&limit=$limit',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        final List rawMenuDays = data?['menuDays'] ?? [];
        final pagination = data?['pagination'];

        setState(() {
          page = pagination?['page'] ?? selectedPage;
          totalPages = pagination?['totalPages'] ?? 1;
          hasNextPage = pagination?['hasNextPage'] == true;
          hasPreviousPage = pagination?['hasPreviousPage'] == true;
          menuDays = rawMenuDays
              .map((item) => MenuDaySummary.fromJson(item))
              .toList();
        });

        return;
      }

      setState(() {
        errorMessage = 'Gagal memuat daftar menu harian.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Tidak dapat terhubung ke server.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void toggleSelection(int menuDayId) {
    setState(() {
      if (selectedIds.contains(menuDayId)) {
        selectedIds.remove(menuDayId);
      } else {
        selectedIds.add(menuDayId);
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectedIds.clear();
    });
  }

  Future<void> confirmDeleteSelected() async {
    if (selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Hapus Menu Terpilih?',
            style: TextStyle(fontWeight: FontWeight.w600, color: textDark),
          ),
          content: Text(
            '${selectedIds.length} menu harian akan dihapus. Data makanan di dalam menu tersebut juga ikut terhapus.',
            style: const TextStyle(
              color: textMedium,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Batal',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await deleteSelected();
    }
  }

  Future<void> deleteSelected() async {
    try {
      setState(() {
        isDeleting = true;
      });

      final response = await http.delete(
        AppConfig.apiUri('/api/screening/client/${widget.clientId}/menu-days'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'menuDayIds': selectedIds.toList()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        exitSelectionMode();
        await fetchMenuDays(targetPage: page);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus menu terpilih')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat terhubung ke server')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  Future<void> openDetail(MenuDaySummary menuDay) async {
    if (isSelectionMode) {
      toggleSelection(menuDay.menuDayId);
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MenuDayDetailPage(menuDayId: menuDay.menuDayId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          isSelectionMode
              ? '${selectedIds.length} dipilih'
              : 'Daftar Menu Harian',
          style: const TextStyle(fontWeight: FontWeight.w800, color: textDark),
        ),
        backgroundColor: background,
        surfaceTintColor: background,
        foregroundColor: textDark,
        elevation: 0,
        leading: isSelectionMode
            ? TextButton(
                onPressed: exitSelectionMode,
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        leadingWidth: isSelectionMode ? 76 : null,
        actions: [
          if (isSelectionMode) ...[
            TextButton(
              onPressed: selectedIds.isEmpty || isDeleting
                  ? null
                  : confirmDeleteSelected,
              child: Text(
                'Hapus',
                style: TextStyle(
                  color: selectedIds.isEmpty ? Colors.grey : Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ] else ...[
            TextButton(
              onPressed: menuDays.isEmpty ? null : enterSelectionMode,
              child: const Text(
                'Pilih',
                style: TextStyle(
                  color: textMedium,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => fetchMenuDays(targetPage: page),
          color: healthGreen,
          child: Builder(
            builder: (context) {
              if (isLoading && menuDays.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: healthGreen),
                );
              }

              if (errorMessage != null) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _InfoCard(
                      title: 'Gagal Memuat Data',
                      message: errorMessage!,
                    ),
                  ],
                );
              }

              if (menuDays.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: const [
                    _InfoCard(
                      title: 'Belum Ada Menu',
                      message: 'Menu harian belum tersedia untuk klien ini.',
                    ),
                  ],
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  ...menuDays.map((menuDay) {
                    final selected = selectedIds.contains(menuDay.menuDayId);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MenuDayCard(
                        menuDay: menuDay,
                        selected: selected,
                        selectionMode: isSelectionMode,
                        onTap: () => openDetail(menuDay),
                        onLongPress: enterSelectionMode,
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  _PaginationFooter(
                    page: page,
                    totalPages: totalPages,
                    hasPreviousPage: hasPreviousPage,
                    hasNextPage: hasNextPage,
                    onPrevious: hasPreviousPage
                        ? () => fetchMenuDays(targetPage: page - 1)
                        : null,
                    onNext: hasNextPage
                        ? () => fetchMenuDays(targetPage: page + 1)
                        : null,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuDayCard extends StatelessWidget {
  const _MenuDayCard({
    required this.menuDay,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  final MenuDaySummary menuDay;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? healthGreen.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? healthGreen.withValues(alpha: 0.55)
                  : const Color(0xFFEDEDED),
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (selectionMode) ...[
                Checkbox(
                  value: selected,
                  onChanged: (_) => onTap(),
                  activeColor: healthGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(menuDay.menuDate),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Energi ${menuDay.energyKcal} • Diet ${menuDay.dietType}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textMedium,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (!selectionMode) ...[
                const SizedBox(width: 10),
                const Text(
                  '›',
                  style: TextStyle(
                    fontSize: 32,
                    height: 1,
                    color: Color(0xFFBDBDBD),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String formatDate(DateTime date) {
    const dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final dayName = dayNames[date.weekday - 1];
    final day = date.day;
    final monthName = monthNames[date.month - 1];
    final year = date.year;

    return '$dayName, $day $monthName $year';
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.page,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onPrevious,
            style: OutlinedButton.styleFrom(
              foregroundColor: healthGreen,
              side: BorderSide(color: healthGreen.withValues(alpha: 0.35)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Sebelumnya',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$page/$totalPages',
          style: const TextStyle(
            color: textMedium,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: healthGreen,
              disabledBackgroundColor: healthGreen.withValues(alpha: 0.25),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Berikutnya',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.message});

  final String title;
  final String message;

  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEDED), width: 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
