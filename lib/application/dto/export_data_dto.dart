import 'package:flutterbase/application/dto/user_dto.dart';
import 'package:flutterbase/application/dto/point_entry_dto.dart';

final class ExportDataDto {
  const ExportDataDto({required this.users, required this.entries});
  final List<UserDto> users;
  final List<PointEntryDto> entries;
}
