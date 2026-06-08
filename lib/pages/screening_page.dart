import 'package:flutter/material.dart';
import 'package:hibah_2026/main.dart';
import 'package:provider/provider.dart';
import 'package:hibah_2026/pages/medicine_step/medicine_step_flow_delegate.dart';

class ScreeningPage extends StatefulWidget {
  const ScreeningPage({super.key});

  @override
  State<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends State<ScreeningPage> {
  late final PageController _controller;
  VoidCallback? _flowListener;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color textDark = Color(0xFF25262A);
  static const Color background = Color(0xFFF7F7F7);

  @override
  void initState() {
    super.initState();

    _controller = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final flow = context.read<FlowController>();

      _flowListener = () {
        if (!_controller.hasClients) return;

        final targetPage = flow.currentIndex;
        final currentPage = _controller.page?.round();

        if (currentPage == targetPage) return;

        _controller.jumpToPage(targetPage);
      };

      flow.addListener(_flowListener!);
    });
  }

  @override
  void dispose() {
    final flow = context.read<FlowController>();

    if (_flowListener != null) {
      flow.removeListener(_flowListener!);
    }

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlowController>(
      builder: (_, flow, _) {
        final delegate = flow.currentStep.delegate;
        final isLastStep = flow.currentIndex == flow.steps.length - 1;
        final pages = flow.steps.map((e) => e.page).toList();

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            foregroundColor: textDark,
            title: const Text(
              'Screening Kesehatan',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: textDark,
              ),
            ),
            centerTitle: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: flow.progress,
                    minHeight: 6,
                    backgroundColor: healthGreenSoft,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      healthGreen,
                    ),
                  ),
                ),
              ),
            ),
          ),

          body: SafeArea(
            top: false,
            bottom: false,
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              children: pages,
            ),
          ),

          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(color: background),

              child: ListenableBuilder(
                listenable: delegate as Listenable,
                builder: (context, _) {
                  final isLoading = delegate.isLoading;

                  return Row(
                    children: [
                      if (flow.canGoBack) ...[
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: healthGreen,
                                disabledForegroundColor: healthGreen.withValues(
                                  alpha: 0.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onPressed: isLoading ? null : flow.prev,
                              child: const Text('Kembali'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],

                      if (!isLastStep)
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: healthGreen,
                                disabledBackgroundColor: healthGreen.withValues(
                                  alpha: 0.35,
                                ),
                                foregroundColor: Colors.white,
                                disabledForegroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      await flow.next();

                                      if (!context.mounted) return;

                                      if (delegate
                                          is MedicineStepFlowDelegate) {
                                        final medicineDelegate = delegate;

                                        if (medicineDelegate
                                            .shouldStopForInsulin) {
                                          await showDialog<void>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(22),
                                                ),
                                                title: const Text(
                                                  'Konsultasi Diperlukan',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                content: const Text(
                                                  'Penggunaan insulin memerlukan penyesuaian diet secara individual. '
                                                  'Silakan konsultasikan dengan dokter penyakit dalam atau ahli gizi sebelum melanjutkan rekomendasi.',
                                                  style: TextStyle(
                                                    height: 1.45,
                                                  ),
                                                ),
                                                actionsPadding:
                                                    const EdgeInsets.fromLTRB(
                                                      20,
                                                      0,
                                                      20,
                                                      16,
                                                    ),
                                                actions: [
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: FilledButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        'Mengerti',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          medicineDelegate
                                              .clearMedicineFields();
                                          flow.stopScreeningAndReset();

                                          return;
                                        }
                                      }
                                    },
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Lanjutkan'),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
