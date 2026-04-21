import 'package:equatable/equatable.dart';
class ColisEntity extends Equatable {
  final String? id;
  final Map<String, dynamic> data;
  const ColisEntity({this.id, required this.data});
  @override List<Object?> get props => [id];
}
