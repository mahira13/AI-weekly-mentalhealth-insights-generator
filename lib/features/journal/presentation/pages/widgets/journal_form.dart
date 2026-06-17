import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../bloc/journal_bloc.dart';
import '../../bloc/journal_event.dart';
import '../../bloc/journal_state.dart';
import 'section_header.dart';
import 'slider_tile.dart';

class JournalForm extends StatelessWidget {
  final JournalLoaded state;

  const JournalForm({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final draft = state.draft;
    final bloc = context.read<JournalBloc>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Positive Symptoms',
            subtitle: 'Racing thoughts, paranoia, unusual perceptions',
          ),
          const SizedBox(height: 8),
          SymptomSliderTile(
            value: draft.positiveSymptom,
            lowLabel: 'None',
            highLabel: 'Severe',
            higherIsBad: true,
            onChanged: (value) =>
                bloc.add(UpdateDraftField(positiveSymptom: value)),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Negative Symptoms',
            subtitle: 'Low motivation, social withdrawal, flat mood',
          ),
          const SizedBox(height: 8),
          SymptomSliderTile(
            value: draft.negativeSymptom,
            lowLabel: 'None',
            highLabel: 'Severe',
            higherIsBad: true,
            onChanged: (value) =>
                bloc.add(UpdateDraftField(negativeSymptom: value)),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Sleep',
            subtitle: 'How was your sleep last night?',
          ),
          const SizedBox(height: 8),
          SymptomSliderTile(
            value: draft.sleepQuality,
            lowLabel: 'Terrible',
            highLabel: 'Excellent',
            higherIsBad: false,
            onChanged: (value) =>
                bloc.add(UpdateDraftField(sleepQuality: value)),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Stress Level',
            subtitle: 'Overall tension or pressure you are feeling',
          ),
          const SizedBox(height: 8),
          SymptomSliderTile(
            value: draft.stressLevel,
            lowLabel: 'Calm',
            highLabel: 'Extreme',
            higherIsBad: true,
            onChanged: (value) =>
                bloc.add(UpdateDraftField(stressLevel: value)),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Social Energy',
            subtitle: 'How socially active or connected do you feel?',
          ),
          const SizedBox(height: 8),
          SymptomSliderTile(
            value: draft.socialEnergy,
            lowLabel: 'Withdrawn',
            highLabel: 'Engaged',
            higherIsBad: false,
            onChanged: (value) =>
                bloc.add(UpdateDraftField(socialEnergy: value)),
          ),
          const SizedBox(height: 32),
          const Text(
            'Notes (optional)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Anything notable today? Your note stays private on this device.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: draft.note,
            maxLines: 3,
            onChanged: (value) => bloc.add(UpdateDraftField(note: value)),
            decoration: InputDecoration(
              hintText: 'e.g. Hard time concentrating, had a good walk...', 
              filled: true,
              fillColor: AppTheme.cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
