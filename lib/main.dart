import 'package:flutter/material.dart';
import 'package:hibah_2026/flow_delegate.dart';
import 'package:hibah_2026/pages/activity_step/activity_step_flow_delegate.dart';
import 'package:hibah_2026/pages/activity_step/activity_step_page.dart';
import 'package:hibah_2026/pages/antropometric_step/antopometric_step_page.dart';
import 'package:hibah_2026/pages/antropometric_step/antropometric_step_flow_delegate.dart';
import 'package:hibah_2026/pages/blood_sugar_status/blood_sugar_status_flow_delegate.dart';
import 'package:hibah_2026/pages/blood_sugar_status/blood_sugar_status_page.dart';
import 'package:hibah_2026/pages/blood_sugar_step/blood_sugar_step_flow_delegate.dart';
import 'package:hibah_2026/pages/blood_sugar_step/blood_sugar_step_page.dart';
import 'package:hibah_2026/pages/clinical_data_step/clinical_data_step_flow_delegate.dart';
import 'package:hibah_2026/pages/clinical_data_step/clinical_data_step_page.dart';
import 'package:hibah_2026/pages/clinical_status/clinical_status_flow_delegate.dart';
import 'package:hibah_2026/pages/clinical_status/clinical_status_page.dart';
import 'package:hibah_2026/pages/energy_needs_status/energy_needs_page.dart';
import 'package:hibah_2026/pages/energy_needs_status/energy_needs_status_flow_delegate.dart';
import 'package:hibah_2026/pages/identity_step/identity_step_flow_delegate.dart';
import 'package:hibah_2026/pages/identity_step/identity_step_page.dart';
import 'package:hibah_2026/pages/medicine_step/medicine_consumption_step_page.dart';
import 'package:hibah_2026/pages/medicine_step/medicine_step_flow_delegate.dart';
import 'package:hibah_2026/pages/nutrition_status/nutrition_status_flow_delegate.dart';
import 'package:hibah_2026/pages/nutrition_status/nutrition_status_page.dart';
import 'package:hibah_2026/pages/screening_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'IBM',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: ChangeNotifierProvider(
        create: (_) => FlowController(),
        child: ScreeningPage(),
      ),
    );
  }
}

class FlowData {
  String? clientId;
  String? screeningId;
  FlowData();
}

class FlowController extends ChangeNotifier {
  late final List<FlowStep> steps;
  final flowData = FlowData();

  int currentIndex = 0;

  FlowController() {
    final identityStepFlowDelegate = IdentityStepFlowDelegate(
      backable: false,
      flowData: flowData,
    );

    final antropometricStepFlowDelegate = AntropometricStepFlowDelegate(
      backable: false,
      flowData: flowData,
    );

    final nutritionStatusFlowDelegate = NutritionStatusFlowDelegate(
      backable: false,
      flowData: flowData,
    );

    final bloodSugarStepFlowDelegate = BloodSugarStepFlowDelegate(
      backable: true,
      flowData: flowData,
    );

    final bloodSugarStatusFlowDelegate = BloodSugarStatusFlowDelegate(
      backable: false,
      flowData: flowData,
    );

    final clinicalDataStepFlowDelegate = ClinicalDataStepFlowDelegate(
      backable: true,
      flowData: flowData,
    );

    final clinicalStatusFlowDelegate = ClinicalStatusFlowDelegate(
      backable: false,
      flowData: flowData,
    );

    final medicineStepFlowDelegate = MedicineStepFlowDelegate(
      backable: true,
      flowData: flowData,
    );

    final activityStepFlowDelegate = ActivityStepFlowDelegate(
      backable: false,
      flowData: flowData,
    );

    final energyStatusFlowDelegate = EnergyNeedsStatusFlowDelegate(
      backable: false,
      flowData: flowData,
    );

    steps = <FlowStep>[
      FlowStep(
        id: 'form1',
        type: StepType.form,
        page: IdentityStepPage(delegate: identityStepFlowDelegate),
        delegate: identityStepFlowDelegate,
      ),
      FlowStep(
        id: 'form2',
        type: StepType.form,
        page: AntopometricStepPage(delegate: antropometricStepFlowDelegate),
        delegate: antropometricStepFlowDelegate,
      ),
      FlowStep(
        id: 'result12',
        type: StepType.result,
        page: NutritionStatusPage(delegate: nutritionStatusFlowDelegate),
        delegate: nutritionStatusFlowDelegate,
      ),
      FlowStep(
        id: 'form3',
        type: StepType.form,
        page: BloodSugarStepPage(delegate: bloodSugarStepFlowDelegate),
        delegate: bloodSugarStepFlowDelegate,
      ),
      FlowStep(
        id: 'result3',
        type: StepType.result,
        page: BloodSugarStatusPage(delegate: bloodSugarStatusFlowDelegate),
        delegate: bloodSugarStatusFlowDelegate,
      ),
      FlowStep(
        id: 'form4',
        type: StepType.form,
        page: ClinicalDataStepPage(delegate: clinicalDataStepFlowDelegate),
        delegate: clinicalDataStepFlowDelegate,
      ),
      FlowStep(
        id: 'result4',
        type: StepType.result,
        page: ClinicalStatusPage(delegate: clinicalStatusFlowDelegate),
        delegate: clinicalStatusFlowDelegate,
      ),
      FlowStep(
        id: 'form5',
        type: StepType.form,
        page: MedicineConsumptionStepPage(delegate: medicineStepFlowDelegate),
        delegate: medicineStepFlowDelegate,
      ),
      FlowStep(
        id: 'form6',
        type: StepType.form,
        page: ActivityStepPage(delegate: activityStepFlowDelegate),
        delegate: activityStepFlowDelegate,
      ),
      FlowStep(
        id: 'result56',
        type: StepType.result,
        page: EnergyNeedsPage(delegate: energyStatusFlowDelegate),
        delegate: energyStatusFlowDelegate,
      ),
    ];
  }

  FlowStep get currentStep => steps[currentIndex];

  double get progress {
    return (currentIndex + 1) / steps.length;
  }

  bool get canGoBack {
    if (currentIndex == 0) return false;

    return currentStep.delegate.canGoBack;
  }

  Future<void> next() async {
    final response = await currentStep.delegate.onNext();

    if (!response.success) return;

    if (currentIndex < steps.length - 1) {
      currentIndex++;
      notifyListeners();
    }
  }

  void prev() {
    if (!canGoBack) return;

    currentIndex--;
    notifyListeners();
  }
}
