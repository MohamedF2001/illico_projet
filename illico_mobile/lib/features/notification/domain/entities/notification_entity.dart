import 'package:equatable/equatable.dart';
class NotificationEntity extends Equatable {
  final String? id;
  final Map<String, dynamic> data;
  const NotificationEntity({this.id, required this.data});
  @override List<Object?> get props => [id];
}
