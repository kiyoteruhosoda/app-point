import 'package:equatable/equatable.dart';

final class PointEntryId extends Equatable {
  const PointEntryId(this.value);
  final int value;
  @override
  List<Object?> get props => [value];
}
