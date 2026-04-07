import 'package:equatable/equatable.dart';

final class UserId extends Equatable {
  const UserId(this.value);
  final int value;
  @override
  List<Object?> get props => [value];
}
