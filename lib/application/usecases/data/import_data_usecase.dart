import 'dart:convert';

import 'package:rewardpoints/domain/repositories/point_entry_repository.dart';
import 'package:rewardpoints/domain/repositories/user_repository.dart';
import 'package:rewardpoints/domain/value_objects/user_id.dart';

final class ImportDataUseCase {
  const ImportDataUseCase(this._userRepo, this._pointRepo);
  final UserRepository _userRepo;
  final PointEntryRepository _pointRepo;

  /// Import from a JSON string. Returns number of imported users.
  Future<int> executeFromJson(String jsonContent) async {
    final Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(jsonContent);
      if (decoded is! Map<String, dynamic>) {
        throw const InvalidImportDataException();
      }
      data = decoded;
    } on FormatException {
      throw const InvalidImportDataException();
    }

    final usersRaw = data['users'];
    final entriesRaw = data['entries'];
    if (usersRaw is! List || entriesRaw is! List) {
      throw const InvalidImportDataException();
    }

    final existingUsers = await _userRepo.getAll();
    for (final u in existingUsers) {
      await _pointRepo.deleteByUserId(u.id);
      await _userRepo.delete(u.id);
    }

    final idMap = <int, int>{};
    for (final u in usersRaw) {
      final map = u as Map<String, dynamic>;
      final user = await _userRepo.create(map['name'] as String);
      idMap[map['id'] as int] = user.id.value;
    }

    for (final e in entriesRaw) {
      final map = e as Map<String, dynamic>;
      final oldUserId = map['userId'] as int;
      final newUserId = idMap[oldUserId];
      if (newUserId == null) continue;
      final userId = UserId(newUserId);
      final dateTime = DateTime.parse(map['dateTime'] as String);
      final points = map['points'] as int;
      final type = map['type'] as String;
      if (type == 'addition') {
        await _pointRepo.addPoints(
          userId: userId,
          dateTime: dateTime,
          points: points,
          reason: map['reason'] as String? ?? '',
        );
      } else if (type == 'consumption') {
        await _pointRepo.consumePoints(
          userId: userId,
          dateTime: dateTime,
          points: points,
          application: map['application'] as String? ?? '',
          tag: map['tag'] as String?,
        );
      }
    }
    return usersRaw.length;
  }
}

final class InvalidImportDataException implements Exception {
  const InvalidImportDataException();
  @override
  String toString() => 'InvalidImportDataException: malformed JSON payload';
}
