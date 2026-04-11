import 'package:flutter_test/flutter_test.dart';
import 'package:rewardpoints/domain/entities/point_entry.dart';
import 'package:rewardpoints/domain/value_objects/point_entry_id.dart';
import 'package:rewardpoints/domain/value_objects/user_id.dart';

void main() {
  final userId = const UserId(1);
  final now = DateTime(2024, 1, 15, 10, 0);

  group('PointAddition', () {
    test('creates with correct fields', () {
      final entry = PointAddition(
        id: const PointEntryId(1),
        userId: userId,
        dateTime: now,
        points: 100,
        reason: 'Bonus',
      );

      expect(entry.id.value, 1);
      expect(entry.userId.value, 1);
      expect(entry.dateTime, now);
      expect(entry.points, 100);
      expect(entry.reason, 'Bonus');
    });

    test('is a PointEntry subtype', () {
      final entry = PointAddition(
        id: const PointEntryId(2),
        userId: userId,
        dateTime: now,
        points: 50,
        reason: 'Gift',
      );
      expect(entry, isA<PointEntry>());
    });
  });

  group('PointConsumption', () {
    test('creates with required fields', () {
      final entry = PointConsumption(
        id: const PointEntryId(3),
        userId: userId,
        dateTime: now,
        points: 30,
        application: 'Store',
      );

      expect(entry.id.value, 3);
      expect(entry.points, 30);
      expect(entry.application, 'Store');
      expect(entry.tag, isNull);
    });

    test('creates with optional tag', () {
      final entry = PointConsumption(
        id: const PointEntryId(4),
        userId: userId,
        dateTime: now,
        points: 20,
        application: 'App',
        tag: 'campaign',
      );

      expect(entry.tag, 'campaign');
    });

    test('is a PointEntry subtype', () {
      final entry = PointConsumption(
        id: const PointEntryId(5),
        userId: userId,
        dateTime: now,
        points: 10,
        application: 'Service',
      );
      expect(entry, isA<PointEntry>());
    });
  });

  group('sealed class exhaustiveness', () {
    test('switch covers all subtypes', () {
      final PointEntry entry = PointAddition(
        id: const PointEntryId(6),
        userId: userId,
        dateTime: now,
        points: 100,
        reason: 'Test',
      );

      final result = switch (entry) {
        PointAddition a => 'addition:${a.reason}',
        PointConsumption c => 'consumption:${c.application}',
      };

      expect(result, 'addition:Test');
    });
  });
}
