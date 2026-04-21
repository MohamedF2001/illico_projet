part of 'zone_model.dart';
ZoneModel _$ZoneModelFromJson(Map<String, dynamic> j) => ZoneModel(
  id: j['_id'] as String?, nom: j['nom'] as String? ?? '',
  description: j['description'] as String?,
  supplement: (j['supplement'] as num?)?.toDouble() ?? 0,
  actif: j['actif'] as bool? ?? true,
);
Map<String, dynamic> _$ZoneModelToJson(ZoneModel i) => {
  if (i.id != null) '_id': i.id, 'nom': i.nom,
  if (i.description != null) 'description': i.description,
  'supplement': i.supplement, 'actif': i.actif,
};
