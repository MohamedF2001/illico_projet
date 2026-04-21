part of 'vehicule_model.dart';
VehiculeModel _$VehiculeModelFromJson(Map<String, dynamic> j) => VehiculeModel(
  id: j['_id'] as String?,
  type: j['type'] as String? ?? '',
  tarifBase: (j['tarifBase'] as num?)?.toDouble() ?? 0,
  coutParKm: j['coutParKm'] != null ? (j['coutParKm'] as num).toDouble() : (j['coutParKm'] as num?)?.toDouble() ?? 0,
  commission: (j['commission'] as num?)?.toDouble() ?? 0,
  description: j['description'] as String?,
  actif: j['actif'] as bool? ?? true,
);
Map<String, dynamic> _$VehiculeModelToJson(VehiculeModel i) => {
  if (i.id != null) '_id': i.id,
  'type': i.type, 'tarifBase': i.tarifBase, 'coutParKm': i.coutParKm,
  'commission': i.commission, if (i.description != null) 'description': i.description,
  'actif': i.actif,
};
