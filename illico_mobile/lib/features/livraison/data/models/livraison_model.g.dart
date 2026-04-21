part of 'livraison_model.dart';

PointAdresseModel _$PointAdresseModelFromJson(Map<String, dynamic> j) => PointAdresseModel(
  adresse: j['adresse'] as String? ?? '',
  coordinates: (j['coordinates'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [0.0, 0.0],
);
Map<String, dynamic> _$PointAdresseModelToJson(PointAdresseModel i) => {'adresse': i.adresse, 'coordinates': i.coordinates};

LivraisonModel _$LivraisonModelFromJson(Map<String, dynamic> j) => LivraisonModel(
  id: j['_id'] as String?,
  client: j['client'],
  livreur: j['livreur'],
  pointDepart: LivraisonModel._pointFromJson(j['pointDepart']),
  pointArrivee: LivraisonModel._pointFromJson(j['pointArrivee']),
  vehicule: j['vehicule'],
  mode: j['mode'] as String? ?? 'express',
  pointIllico: j['pointIllico'],
  statut: j['statut'] as String? ?? 'en_attente',
  prixEstime: (j['prixEstime'] as num?)?.toDouble() ?? 0,
  prixFinal: (j['prixFinal'] as num?)?.toDouble(),
  modePaiement: j['modePaiement'] as String?,
  otpValide: j['otpValidé'] as bool? ?? false,
  preuveLivraisonUrl: j['preuveLivraisonUrl'] as String?,
  noteLivreur: (j['noteLivreur'] as num?)?.toDouble(),
  urgent: j['urgent'] as bool? ?? false,
  nuit: j['nuit'] as bool? ?? false,
  poids: (j['poids'] as num?)?.toDouble() ?? 1,
  dateCreation: j['dateCreation'] != null ? DateTime.tryParse(j['dateCreation'] as String) : null,
  dateLivraison: j['dateLivraison'] != null ? DateTime.tryParse(j['dateLivraison'] as String) : null,
);
Map<String, dynamic> _$LivraisonModelToJson(LivraisonModel i) => {
  if (i.id != null) '_id': i.id,
  'pointDepart': LivraisonModel._pointToJson(i.pointDepart),
  'pointArrivee': LivraisonModel._pointToJson(i.pointArrivee),
  'vehicule': LivraisonModel._dynToJson(i.vehicule),
  'mode': i.mode, 'prixEstime': i.prixEstime, 'statut': i.statut,
};
