// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'user_model.dart';

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) => LocationModel(
  type: json['type'] as String? ?? 'Point',
  coordinates: (json['coordinates'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
);
Map<String, dynamic> _$LocationModelToJson(LocationModel i) => <String, dynamic>{
  'type': i.type, 'coordinates': i.coordinates,
};

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['_id'] as String?,
  nom: json['nom'] as String? ?? '',
  role: json['role'] as String? ?? 'Client',
  telephone: json['telephone'] as String?,
  email: json['email'] as String?,
  typeClient: json['typeClient'] as String?,
  adresse: json['adresse'] as String?,
  soldeIllico: (json['soldeIllico'] as num?)?.toDouble(),
  forfaitActif: json['forfaitActif'],
  vehicule: json['vehicule'],
  statut: json['statut'] as String?,
  scoreNote: (json['scoreNote'] as num?)?.toDouble(),
  cashCollecte: (json['cashCollecte'] as num?)?.toDouble(),
  cashReverse: (json['cashReverse'] as num?)?.toDouble(),
  valide: json['valide'] as bool?,
  photoProfil: json['photoProfil'] as String?,
  actif: json['actif'] as bool?,
  commissionTotal: (json['commissionTotal'] as num?)?.toDouble(),
  location: UserModel._locationFromJson(json['location']),
);
Map<String, dynamic> _$UserModelToJson(UserModel i) => <String, dynamic>{
  if (i.id != null) '_id': i.id,
  'nom': i.nom, 'role': i.role,
  if (i.telephone != null) 'telephone': i.telephone,
  if (i.email != null) 'email': i.email,
};
