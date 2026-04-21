class Validators {
  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Ce champ est requis.' : null;

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Numéro requis.';
    if (!RegExp(r'^\+?[0-9\s\-()]{8,15}$').hasMatch(v)) return 'Numéro invalide.';
    return null;
  }

  static String? pin(String? v) {
    if (v == null || v.isEmpty) return 'PIN requis.';
    if (!RegExp(r'^\d{4,6}$').hasMatch(v)) return '4 à 6 chiffres.';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Mot de passe requis.';
    if (v.length < 6) return '6 caractères minimum.';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email requis.';
    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)) return 'Email invalide.';
    return null;
  }

  static String? otp(String? v) {
    if (v == null || v.isEmpty) return 'OTP requis.';
    if (!RegExp(r'^\d{6}$').hasMatch(v)) return '6 chiffres requis.';
    return null;
  }

  static String? positiveNumber(String? v) {
    if (v == null || v.isEmpty) return 'Valeur requise.';
    if (double.tryParse(v) == null) return 'Nombre invalide.';
    if (double.parse(v) < 0) return 'Doit être positif.';
    return null;
  }
}
