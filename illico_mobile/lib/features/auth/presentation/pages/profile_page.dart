import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isEditing = false;
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _adresseController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nomController = TextEditingController(text: user?.nom);
    _emailController = TextEditingController(text: user?.email);
    _adresseController = TextEditingController(text: user?.adresse);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (image != null) {
      bool success;
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        success =
            await ref.read(authProvider.notifier).updatePhoto(bytes, isWeb: true);
      } else {
        success = await ref.read(authProvider.notifier)
            .updatePhoto(image.path, isWeb: false);
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo de profil mise à jour'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Échec de l\'upload: ${error?.displayMessage ?? 'Erreur inconnue'}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final success = await ref.read(authProvider.notifier).updateProfile({
      'nom': _nomController.text,
      'email': _emailController.text,
      'adresse': _adresseController.text,
    });
    if (success) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isLivreur = user?.role == 'Livreur';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.save, color: AppColors.primary),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: auth.isLoading && user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Photo de profil ────────────────────────
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
                          backgroundImage: user?.photoProfil != null
                              ? NetworkImage(user!.photoProfil!)
                              : null,
                          child: user?.photoProfil == null
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── User Info Card ────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        if (_isEditing) ...[
                          _buildEditField('Nom', _nomController),
                          const SizedBox(height: 16),
                          _buildEditField('Email', _emailController),
                          const SizedBox(height: 16),
                          _buildEditField('Adresse', _adresseController),
                        ] else ...[
                          Text(
                            user?.nom ?? 'Utilisateur',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            user?.role == 'Livreur' ? 'Livreur ILLICO' : 'Client ILLICO',
                            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(user?.telephone ?? '', style: const TextStyle(color: Colors.black54)),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Score',
                                value: '${user?.scoreNote?.toStringAsFixed(1) ?? '4.5'}/5',
                                labelColor: AppColors.info,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatCard(
                                label: isLivreur ? 'Cash' : 'Wallet',
                                value: isLivreur
                                  ? Formatters.currency(user?.cashSolde ?? 0)
                                  : Formatters.currency(user?.soldeIllico ?? 0),
                                labelColor: isLivreur && (user?.estBloque ?? false) ? AppColors.danger : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (isLivreur) ...[
                    const SizedBox(height: 24),
                    const Text('Statistiques financières', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    _InfoRow(label: 'Cash Collecté', value: Formatters.currency(user?.cashCollecte ?? 0)),
                    _InfoRow(label: 'Cash Reversé', value: Formatters.currency(user?.cashReverse ?? 0)),
                    _InfoRow(label: 'Commission Totale', value: Formatters.currency(user?.commissionTotal ?? 0)),
                  ],

                  const SizedBox(height: 32),
                  const Text('Préférences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  const _PreferenceItem(title: 'Sécurité', subtitle: 'Code PIN, Appareils'),
                  const _PreferenceItem(title: 'Notifications', subtitle: 'Push, SMS'),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Déconnexion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  const _StatCard({required this.label, required this.value, required this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: labelColor, fontWeight: FontWeight.w900, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PreferenceItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _PreferenceItem({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.settings_outlined, color: AppColors.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              if (subtitle != null) Text(subtitle!, style: const TextStyle(color: Colors.black54, fontSize: 13)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }
}
