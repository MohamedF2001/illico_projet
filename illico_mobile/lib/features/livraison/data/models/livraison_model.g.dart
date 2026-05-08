part of 'livraison_model.dart';

PointAdresseModel _$PointAdresseModelFromJson(Map<String, dynamic> j) =>
    PointAdresseModel(
      nomContact: (j['nomExpediteur'] ?? j['nomDestinataire'] ?? j['nomContact'] ?? '') as String,
      adresse: j['adresse'] as String? ?? '',
      telephoneContact: j['telephoneContact'] as String? ?? '',
      coordinates: (j['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0.0, 0.0],
    );
Map<String, dynamic> _$PointAdresseModelToJson(PointAdresseModel i) => {
      'nomContact': i.nomContact,
      'adresse': i.adresse,
      'telephoneContact': i.telephoneContact,
      'coordinates': i.coordinates
    };

LivraisonModel _$LivraisonModelFromJson(Map<String, dynamic> j) =>
    LivraisonModel(
      id: j['_id'] as String?,
      client: j['client'],
      livreur: j['livreur'],
      codeSuivi: j['codeSuivi'] as String?,
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
      otpLivraison: j['otpLivraison'] as String?,
      otpRetrait: j['otpRetrait'] as String?,
      natureColis: j['natureColis'] as String?,
      preuveLivraisonUrl: j['preuveLivraisonUrl'] as String?,
      noteLivreur: (j['noteLivreur'] as num?)?.toDouble(),
      urgent: j['urgent'] as bool? ?? false,
      nuit: j['nuit'] as bool? ?? false,
      poids: (j['poids'] as num?)?.toDouble() ?? 1,
      dateCreation: j['dateCreation'] != null
          ? DateTime.tryParse(j['dateCreation'] as String)
          : null,
      dateLivraison: j['dateLivraison'] != null
          ? DateTime.tryParse(j['dateLivraison'] as String)
          : null,
    );
Map<String, dynamic> _$LivraisonModelToJson(LivraisonModel i) => {
      if (i.id != null) '_id': i.id,
      'client': LivraisonModel._dynToJson(i.client),
      'livreur': LivraisonModel._dynToJson(i.livreur),
      'codeSuivi': i.codeSuivi,
      'pointDepart': LivraisonModel._pointToJson(i.pointDepart),
      'pointArrivee': LivraisonModel._pointToJson(i.pointArrivee),
      'vehicule': LivraisonModel._dynToJson(i.vehicule),
      'mode': i.mode,
      'pointIllico': LivraisonModel._dynToJson(i.pointIllico),
      'statut': i.statut,
      'prixEstime': i.prixEstime,
      'prixFinal': i.prixFinal,
      'modePaiement': i.modePaiement,
      'otpValidé': i.otpValide,
      'otpLivraison': i.otpLivraison,
      'otpRetrait': i.otpRetrait,
      'natureColis': i.natureColis,
      'preuveLivraisonUrl': i.preuveLivraisonUrl,
      'noteLivreur': i.noteLivreur,
      'urgent': i.urgent,
      'nuit': i.nuit,
      'poids': i.poids,
      'dateCreation': i.dateCreation?.toIso8601String(),
      'dateLivraison': i.dateLivraison?.toIso8601String(),
    };
