import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/identity_step/identity_step_flow_delegate.dart';
import 'package:hibah_2026/widgets/form_header_widget.dart';
import 'package:hibah_2026/widgets/gender_radio_group_widget.dart';

class IdentityStepPage extends StatefulWidget {
  const IdentityStepPage({super.key, required this.delegate});

  final IdentityStepFlowDelegate delegate;

  @override
  State<IdentityStepPage> createState() => IdentityStepPageState();
}

class IdentityStepPageState extends State<IdentityStepPage> {
  final formKey = GlobalKey<FormState>();

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color textMedium = Color(0xFF666666);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FormHeader(
            title: 'Identitas Diri',
            subtitle:
                'Lengkapi data diri agar hasil screening dan rekomendasi lebih sesuai.',
          ),

          const SizedBox(height: 28),

          Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: widget.delegate.nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: cleanInputDecoration(
                    label: 'Nama',
                    hint: 'Contoh: Roel',
                    icon: Icons.person_rounded,
                  ),
                ),

                const SizedBox(height: 22),

                TextFormField(
                  controller: widget.delegate.ageController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: cleanInputDecoration(
                    label: 'Usia',
                    hint: 'Contoh: 23',
                    icon: Icons.person,
                    suffix: 'tahun',
                  ),
                ),

                const SizedBox(height: 24),

                ListenableBuilder(
                  listenable: widget.delegate,
                  builder: (context, _) {
                    return GenderSection(
                      child: GenderRadioGroupWidget(
                        value: widget.delegate.gender,
                        onChanged: (Gender? value) {
                          widget.delegate.setGender(value);
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: widget.delegate.occupationController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: cleanInputDecoration(
                    label: 'Pekerjaan',
                    hint: 'Contoh: Mahasiswa',
                    icon: Icons.work_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration cleanInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      // Updated icon color to a professional gray (textMedium)
      prefixIcon: Icon(icon, color: textMedium, size: 21),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(
        color: textMedium,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w500,
      ),
      suffixStyle: const TextStyle(
        color: healthGreen,
        fontWeight: FontWeight.w800,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: borderSoft, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: healthGreen, width: 1.6),
      ),
    );
  }
}

class GenderSection extends StatelessWidget {
  const GenderSection({super.key, required this.child});

  final Widget child;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color greySoft = Color(
    0xFFF4F4F5,
  ); // Added a neutral background color
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderSoft, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: greySoft, // Updated to a professional light gray
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wc_rounded,
                  color: textMedium, // Updated to gray
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                'Jenis Kelamin',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'Pilih sesuai data diri Anda.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          child,
        ],
      ),
    );
  }
}
