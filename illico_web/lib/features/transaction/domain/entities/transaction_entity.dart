import 'package:equatable/equatable.dart';
class TransactionEntity extends Equatable {
  final String? id;
  final Map<String, dynamic> data;
  const TransactionEntity({this.id, required this.data});
  @override List<Object?> get props => [id];
}
