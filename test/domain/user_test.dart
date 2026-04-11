import 'package:flutter_test/flutter_test.dart';
import 'package:rewardpoints/domain/entities/user.dart';
import 'package:rewardpoints/domain/value_objects/user_id.dart';

void main() {
  final createdAt = DateTime(2024, 1, 10);

  group('User entity', () {
    test('creates with correct fields', () {
      const id = UserId(1);
      final user = User(id: id, name: 'Alice', createdAt: createdAt);

      expect(user.id.value, 1);
      expect(user.name, 'Alice');
      expect(user.createdAt, createdAt);
    });

    test('copyWith preserves unchanged fields', () {
      const id = UserId(2);
      final user = User(id: id, name: 'Bob', createdAt: createdAt);
      final updated = user.copyWith(name: 'Charlie');

      expect(updated.id, id);
      expect(updated.name, 'Charlie');
      expect(updated.createdAt, createdAt);
    });

    test('copyWith replaces all fields', () {
      const id = UserId(3);
      final user = User(id: id, name: 'Dave', createdAt: createdAt);
      final newDate = DateTime(2025, 6, 1);
      final updated = user.copyWith(
        id: const UserId(99),
        name: 'Eve',
        createdAt: newDate,
      );

      expect(updated.id.value, 99);
      expect(updated.name, 'Eve');
      expect(updated.createdAt, newDate);
    });
  });

  group('UserId value object', () {
    test('equality works via Equatable', () {
      expect(const UserId(1), const UserId(1));
      expect(const UserId(1), isNot(const UserId(2)));
    });
  });
}
