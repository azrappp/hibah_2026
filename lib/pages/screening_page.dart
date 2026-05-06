import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/activity_step_page.dart';
import 'package:hibah_2026/pages/antopometric_step_page.dart';
import 'package:hibah_2026/pages/blood_sugar_status_page.dart';
import 'package:hibah_2026/pages/blood_sugar_step_page.dart';
import 'package:hibah_2026/pages/clinical_data_step_page.dart';
import 'package:hibah_2026/pages/clinical_status_page.dart';
import 'package:hibah_2026/pages/energy_needs_page.dart';
import 'package:hibah_2026/pages/identity_step_page.dart';
import 'package:hibah_2026/pages/medicine_consumption_step_page.dart';
import 'package:hibah_2026/pages/nutrition_status_page.dart';

class ScreeningPage extends StatefulWidget {
  const ScreeningPage({super.key});

  @override
  State<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends State<ScreeningPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            // ignore: deprecated_member_use
            year2023: false,
            trackGap: 8.0,
            value: (_currentPage + 1) / 10,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: _controller,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (value) => setState(() {
                _currentPage = value;
              }),
              children: <Widget>[
                IdentityStepPage(),
                AntopometricStepPage(),
                NutritionStatusPage(),
                BloodSugarStepPage(),
                BloodSugarStatusPage(),
                ClinicalDataStepPage(),
                ClinicalStatusPage(),
                MedicineConsumptionStepPage(),
                ActivityStepPage(),
                EnergyNeedsPage(),
              ],
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
                if (_currentPage > 0)
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
                      onPressed: () => _controller.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      ),
                      child: Text("Kembali"),
                    ),
                  ),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      fixedSize: Size.fromHeight(56.0),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () => _controller.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    ),
                    child: Text(_currentPage == 10 ? "Submit" : "Lanjutkan"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
