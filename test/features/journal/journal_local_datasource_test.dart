import 'dart:io';

import 'package:ai_mental_health_insights/core/utils/constants.dart';
import 'package:ai_mental_health_insights/features/journal/data/datasources/journal_local_datasource.dart';
import 'package:ai_mental_health_insights/features/journal/data/models/journal_entry_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late Box<JournalEntryModel> box;
  late JournalLocalDataSourceImpl dataSource;

  setUpAll(() {
    Hive.registerAdapter(JournalEntryModelAdapter());
  });

  setUp(() async {
    tempDir =
        await Directory.systemTemp.createTemp('journal_local_datasource_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<JournalEntryModel>(AppConstants.journalBoxName);
    dataSource = JournalLocalDataSourceImpl(box: box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(AppConstants.journalBoxName);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('seedDemoData replaces contents with 7 entries including today',
      () async {
    await dataSource.seedDemoData();

    final entries = await dataSource.getAllEntries();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    expect(entries, hasLength(AppConstants.weekDays));
    expect(
      entries.any(
        (entry) =>
            entry.date.year == todayDate.year &&
            entry.date.month == todayDate.month &&
            entry.date.day == todayDate.day,
      ),
      isTrue,
    );
  });
}
