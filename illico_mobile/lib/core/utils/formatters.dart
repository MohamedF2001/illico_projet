import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount) =>
      '${NumberFormat('#,###', 'fr_FR').format(amount)} FCFA';

  static String date(DateTime? d) =>
      d == null ? '-' : DateFormat('dd/MM/yyyy', 'fr_FR').format(d);

  static String dateTime(DateTime? d) =>
      d == null ? '-' : DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(d);

  static String timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours}h';
    return Formatters.date(d);
  }

  static String statutLabel(String statut) => switch (statut) {
    'en_attente'      => 'En attente',
    'affecté'         => 'Affecté',
    'arrivé_pickup'   => 'Arrivé au pickup',
    'colis_récupéré'  => 'Colis récupéré',
    'déposé_en_point' => 'En point ILLICO',
    'livré'           => 'Livré',
    'échoué'          => 'Échoué',
    'annulé'          => 'Annulé',
    'receptionné'     => 'Réceptionné',
    'retiré'          => 'Retiré',
    'retourné'        => 'Retourné',
    'en_ligne'        => 'En ligne',
    'hors_ligne'      => 'Hors ligne',
    'en_mission'      => 'En mission',
    _                 => statut,
  };

  static String vehiculeLabel(String type) => switch (type) {
    'velo'       => 'Vélo',
    'moto'       => 'Moto',
    'tricycle'   => 'Tricycle',
    'voiture'    => 'Voiture',
    'camionnette'=> 'Camionnette',
    _            => type,
  };
}
