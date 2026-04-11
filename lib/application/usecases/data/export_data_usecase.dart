import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:rewardpoints/domain/entities/point_entry.dart';
import 'package:rewardpoints/domain/repositories/point_entry_repository.dart';
import 'package:rewardpoints/domain/repositories/user_repository.dart';

final class ExportDataUseCase {
  const ExportDataUseCase(this._userRepo, this._pointRepo);
  final UserRepository _userRepo;
  final PointEntryRepository _pointRepo;

  Future<String> execute() async {
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

    final data = jsonEncode({'users': usersJson, 'entries': entriesJson});
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/point_data_export.json');
    await file.writeAsString(data);
    return file.path;
  }
}
