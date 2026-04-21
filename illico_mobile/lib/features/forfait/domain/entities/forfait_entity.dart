import 'package:equatable/equatable.dart';
class ForfaitEntity extends Equatable {
  final String? id;
  final Map<String, dynamic> data;
  const ForfaitEntity({this.id, required this.data});
  @override List<Object?> get props => [id];
}
