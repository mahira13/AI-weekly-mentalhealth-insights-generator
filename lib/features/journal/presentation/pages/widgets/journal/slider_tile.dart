import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';

class SymptomSliderTile extends StatelessWidget {
  const SymptomSliderTile({
    super.key,
    required this.value,
    required this.lowLabel,
    required this.highLabel,
    required this.higherIsBad,
    required this.onChanged,
  });
  final double value;
  final String lowLabel;
  final String highLabel;
  final bool higherIsBad;
  final ValueChanged<double> onChanged;

  Color get _color {
    if (higherIsBad) {
      if (value <= 3) return AppTheme.sliderGood;
      if (value <= 6) return AppTheme.sliderMedium;
      return AppTheme.sliderBad;
    }

    if (value <= 3) return AppTheme.sliderBad;
    if (value <= 6) return AppTheme.sliderMedium;
    return AppTheme.sliderGood;
  }

  String get _emoji {
    if (!higherIsBad) {
      // Higher = better (sleep, social)
      if (value <= 3) return '😔';
      if (value <= 6) return '😐';
      return '😊';
    } else {
      // Higher = worse (symptoms, stress)
      if (value <= 3) return '😌';
      if (value <= 6) return '😕';
      return '😰';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: color,
                    inactiveTrackColor: color.withOpacity(0.15),
                    thumbColor: color,
                  ),
                  child: Slider(
                    value: value,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${value.round()}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lowLabel,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
                Text(highLabel,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
