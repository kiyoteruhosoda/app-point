import 'dart:convert';

import 'package:rewardpoints/domain/entities/point_entry.dart';
import 'package:rewardpoints/domain/repositories/point_entry_repository.dart';
import 'package:rewardpoints/domain/repositories/user_repository.dart';

final class ExportDataResult {
  const ExportDataResult({required this.json, required this.suggestedFileName});
  final String json;
  final String suggestedFileName;
}

final class ExportDataUseCase {
  const ExportDataUseCase(this._userRepo, this._pointRepo);
  final UserRepository _userRepo;
  final PointEntryRepository _pointRepo;

  Future<ExportDataResult> execute({DateTime? now}) async {
    final users = await _userRepo.getAll();
    final usersJson = <Map<String, dynamic>>[];
    final entriesJson = <Map<String, dynamic>>[];

    for (final user in users) {
      usersJson.add({
        'id': user.id.value,
        'name': user.name,
        'createdAt': user.createdAt.toIso8601String(),
      });
      final entries = await _pointRepo.getByUserId(user.id);
      for (final entry in entries) {
        final map = <String, dynamic>{
          'id': entry.id.value,
          'userId': entry.userId.value,
          'dateTime': entry.dateTime.toIso8601String(),
          'points': entry.points,
        };
        if (entry is PointAddition) {
          map['type'] = 'addition';
          map['reason'] = entry.reason;
        } else if (entry is PointConsumption) {
          map['type'] = 'consumption';
          map['application'] = entry.application;
          if (entry.tag != null) map['tag'] = entry.tag;
        }
        entriesJson.add(map);
      }
    }

    final json = jsonEncode({'users': usersJson, 'entries': entriesJson});
    final ts = now ?? DateTime.now();
    final fileName =
        'point_data_${_fmt(ts.year, 4)}${_fmt(ts.month, 2)}${_fmt(ts.day, 2)}'
        '_${_fmt(ts.hour, 2)}${_fmt(ts.minute, 2)}.json';
    return ExportDataResult(json: json, suggestedFileName: fileName);
  }

  String _fmt(int v, int width) => v.toString().padLeft(width, '0');
}
