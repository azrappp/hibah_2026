import 'package:flutter/material.dart';
import 'package:hibah_2026/main.dart';
import 'package:provider/provider.dart';

class ScreeningPage extends StatefulWidget {
  const ScreeningPage({super.key});

  @override
  State<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends State<ScreeningPage> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final flow = context.read<FlowController>();

      flow.addListener(() {
        _controller.animateToPage(
          flow.currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlowController>(
      builder: (_, flow, _) {
        final delegate = flow.currentStep.delegate;
        return Scaffold(
          appBar: AppBar(
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(4.0),
              child: LinearProgressIndicator(
                // ignore: deprecated_member_use
                year2023: false,
                trackGap: 8.0,
                value: flow.progress,
              ),
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: NeverScrollableScrollPhysics(),
                  children: flow.steps.map((e) => e.page).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 32.0,
                ),
                child: Row(
                  spacing: 16.0,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (flow.canGoBack)
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            fixedSize: Size.fromHeight(56.0),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          onPressed: flow.prev,
                          child: Text("Kembali"),
                        ),
                      ),

                    if (flow.currentIndex != flow.steps.length - 1)
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            fixedSize: Size.fromHeight(56.0),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                          onPressed: delegate.isLoading
                              ? null
                              : () async => await flow.next(),
                          child: Text('Lanjutkan'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
