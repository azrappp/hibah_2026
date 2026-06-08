import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hibah_2026/config/app_config.dart';
import 'package:hibah_2026/models/screening_summary_model.dart';
import 'package:hibah_2026/pages/screening_history/screening_detail_page.dart';
import 'package:http/http.dart' as http;

class ScreeningHistoryListPage extends StatefulWidget {
  const ScreeningHistoryListPage({super.key, required this.clientId});

  final String clientId;

  @override
  State<ScreeningHistoryListPage> createState() =>
      _ScreeningHistoryListPageState();
}

class _ScreeningHistoryListPageState extends State<ScreeningHistoryListPage> {
  static const Color healthGreen = Color(0xFF04C83A);
  static const Color background = Color(0xFFF7F7F7);
  static const Color textDark = Color(0xFF25262A);

  bool isLoading = false;
  String? errorMessage;
  List<ScreeningSummary> screenings = [];

  @override
  void initState() {
    super.initState();
    fetchScreenings();
  }

  Future<void> fetchScreenings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        AppConfig.apiUri('/api/screening/client/${widget.clientId}'),
        headers: {'Accept': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'] ?? [];

        setState(() {
          screenings = data
              .map((item) => ScreeningSummary.fromJson(item))
              .toList();
        });

        return;
      }

      setState(() {
        errorMessage = 'Gagal memuat daftar screening.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Daftar Screening',
          style: TextStyle(fontWeight: FontWeight.w800, color: textDark),
        ),
        backgroundColor: background,
        surfaceTintColor: background,
        foregroundColor: textDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchScreenings,
          color: healthGreen,
          child: Builder(
            builder: (context) {
              if (isLoading) {
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
                      icon: Icons.error_outline_rounded,
                    ),
                  ],
                );
              }

              if (screenings.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: const [
                    _InfoCard(
                      title: 'Belum Ada Screening',
                      message: 'Data screening belum tersedia untuk klien ini.',
                      icon: Icons.assignment_outlined,
                    ),
                  ],
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                itemCount: screenings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = screenings[index];
                  return _ScreeningHistoryCard(
                    screening: item,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScreeningDetailPage(
                            screeningId: item.screeningId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScreeningHistoryCard extends StatelessWidget {
  const _ScreeningHistoryCard({required this.screening, required this.onTap});

  final ScreeningSummary screening;
  final VoidCallback onTap;

  static const Color textDark = Color(0xFF25262A);

  @override
  Widget build(BuildContext context) {
    final dateText = formatDate(screening.createdAt.toLocal());

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEDEDED), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateText,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: textDark,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFBDBDBD),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(label: screening.diabetesStatus ?? 'DM: -'),
                  _StatusChip(label: screening.hypertensionStatus ?? 'HT: -'),
                  _StatusChip(label: screening.obesityStatus ?? 'Obesitas: -'),
                ],
              ),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF666666),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  static const Color healthGreen = Color(0xFF04C83A);
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
          Icon(icon, size: 42, color: healthGreen),
          const SizedBox(height: 14),
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
