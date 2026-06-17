import 'package:flutter/material.dart';
import '../../../../domain/entities/journal_entry.dart';
import 'timeline_chart_section.dart';
import 'timeline_entry_list.dart';
import 'timeline_summary_card.dart';
import 'timeline_view_data_mapper.dart';

class TimelineContent extends StatelessWidget {
  const TimelineContent({
    super.key,
    required this.entries,
  });

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final viewData = const TimelineViewDataMapper().map(
      entries,
      now: DateTime.now(),
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TimelineSummaryCard(summary: viewData.summary),
        const SizedBox(height: 20),
        TimelineChartSection(weekSlots: viewData.weekSlots),
        const SizedBox(height: 24),
        TimelineEntryList(entries: viewData.recentEntries),
      ],
    );
  }
}
