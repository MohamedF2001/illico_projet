import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/map_picker.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../vehicule/presentation/providers/vehicule_provider.dart';
import '../../../vehicule/domain/entities/vehicule_entity.dart';
import '../providers/livraison_provider.dart';
import '../../data/repositories/livraison_repository_impl.dart';
import '../../data/datasources/livraison_remote_datasource.dart';
import '../../../../core/api/api_client.dart';

class CreateLivraisonPage extends ConsumerStatefulWidget {
  const CreateLivraisonPage({super.key});

  @override
  ConsumerState<CreateLivraisonPage> createState() => _CreateLivraisonPageState();
}

class _CreateLivraisonPageState extends ConsumerState<CreateLivraisonPage> {
  double _poids = 1.0;
  bool _urgent = false;
  bool _nuit = false;
  String _modePaiement = 'cash';
  int _currentStep = 0;

  // Step 1: Mode
  String? _selectedMode;

  // Step 2: Addresses & Info
  final _departNomController = TextEditingController();
  final _departController = TextEditingController();
  final _departTelController = TextEditingController();
  LatLng? _departCoords;

  final _arriveeNomController = TextEditingController();
  final _arriveeController = TextEditingController();
  final _arriveeTelController = TextEditingController();
  LatLng? _arriveeCoords;

  final _natureController = TextEditingController();

  // Step 3: Vehicle
  VehiculeEntity? _selectedVehicule;

  // Step 4: Summary & Estimation
  Map<String, dynamic>? _estimation;
  bool _isEstimating = false;
  bool _isCreating = false;

  // Step 5: Success
  String? _createdLivraisonId;

  final _repo = LivraisonRepositoryImpl(LivraisonRemoteDataSource(apiClient));

  @override
  void dispose() {
    _departNomController.dispose();
    _departController.dispose();
    _departTelController.dispose();
    _arriveeNomController.dispose();
    _arriveeController.dispose();
    _arriveeTelController.dispose();
    _natureController.dispose();
    super.dispose();
  }

  Future<void> _getEstimation() async {
    if (_departCoords == null || _arriveeCoords == null || _selectedVehicule == null) return;

    setState(() => _isEstimating = true);

    final r = await _repo.estimatePrice({
      'vehicule': _selectedVehicule!.id,
      'coordDepart': [_departCoords!.longitude, _departCoords!.latitude],
      'coordArrivee': [_arriveeCoords!.longitude, _arriveeCoords!.latitude],
      'mode': _selectedMode,
      'poids': _poids,
      'urgent': _urgent,
      'nuit': _nuit,
      'pointIllico': _selectedMode == 'point_illico' ? 'true' : null,
    });

    r.fold(
          (f) {
        setState(() => _isEstimating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.displayMessage)));
      },
          (data) {
        setState(() {
          _estimation = data;
          _isEstimating = false;
          _currentStep = 3;
        });
      },
    );
  }

  Future<void> _createLivraison() async {
    setState(() => _isCreating = true);

    final r = await _repo.create({
      'pointDepart': {
        'nomExpediteur': _departNomController.text,
        'adresse': _departController.text,
        'telephoneContact': _departTelController.text,
        'coordinates': [_departCoords!.longitude, _departCoords!.latitude],
      },
      'pointArrivee': {
        'nomDestinataire': _arriveeNomController.text,
        'adresse': _arriveeController.text,
        'telephoneContact': _arriveeTelController.text,
        'coordinates': [_arriveeCoords!.longitude, _arriveeCoords!.latitude],
      },
      'vehicule': _selectedVehicule!.id,
      'mode': _selectedMode,
      'natureColis': _natureController.text,
      'poids': _poids,
      'modePaiement': _modePaiement,
      'urgent': _urgent,
      'nuit': _nuit,
    });

    r.fold(
          (f) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.displayMessage)));
      },
          (l) {
        ref.read(livraisonListProvider.notifier).load();
        setState(() {
          _isCreating = false;
          _createdLivraisonId = l.id;
          _currentStep = 4; // Success step
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _currentStep == 4
          ? null // Pas d'AppBar sur l'écran de succès
          : AppBar(
        backgroundColor: const Color(0xFFE5E5E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.flash_on, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'ILLICO',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_currentStep < 4) _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildCurrentStep(),
            ),
          ),
          if (_currentStep < 4) _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFFE5E5E5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: index <= _currentStep ? AppColors.primary : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildStepMode();
      case 1: return _buildStepAddresses();
      case 2: return _buildStepVehicule();
      case 3: return _buildStepSummary();
      case 4: return _buildStepSuccess();
      default: return const SizedBox();
    }
  }

  // ─── ÉTAPE SUCCÈS ───────────────────────────────────────────────────────────
  Widget _buildStepSuccess() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation / Icône de succès
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.accent,
              size: 64,
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'Commande confirmée !',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Votre livraison a été créée avec succès.\nUn livreur sera affecté sous peu.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),

          // Bouton principal : Suivre la livraison
          if (_createdLivraisonId != null)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => context.pushReplacement('/livraison/$_createdLivraisonId'),
                icon: const Icon(Icons.location_on_rounded, color: Colors.white),
                label: const Text(
                  'Suivre ma livraison',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          const SizedBox(height: 14),

          // Bouton secondaire : Retour à l'accueil
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home_rounded, color: Color(0xFF1A1A2E)),
              label: const Text(
                'Retour à l\'accueil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Info tip
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Retrouvez et annulez votre livraison depuis l\'historique ou les récents.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comment préférez\nvous recevoir ?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1)),
        const SizedBox(height: 12),
        const Text('Choisissez la vitesse ou l\'économie', style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 32),
        _ModeCard(
          title: 'Livraison Express',
          subtitle: 'Directement à votre porte en moins de 30 minutes',
          footer: 'Arrivée estimée 14:45',
          badgeText: 'Le plus rapide',
          badgeColor: const Color(0xFFFFD5A1),
          isSelected: _selectedMode == 'express',
          onTap: () => setState(() => _selectedMode = 'express'),
          iconColor: const Color(0xFFF7B97D),
        ),
        const SizedBox(height: 16),
        _ModeCard(
          title: 'Point ILLICO',
          subtitle: 'Retrait en point de collecte à prix réduit',
          footer: 'À 450m . Pharmacie',
          badgeText: '-30% Réduction',
          badgeColor: const Color(0xFF8BB3FF),
          isSelected: _selectedMode == 'point_illico',
          onTap: () => setState(() => _selectedMode = 'point_illico'),
          iconColor: const Color(0xFF86A8E7),
          borderColor: const Color(0xFF3366FF),
        ),
      ],
    );
  }

  Widget _buildStepAddresses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Où allons-nous ?',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
        const SizedBox(height: 32),
        _buildAddressField(
          label: 'Point de départ',
          nomLabel: 'Nom de l\'expéditeur',
          nomController: _departNomController,
          controller: _departController,
          telController: _departTelController,
          isDepart: true,
          onMapPick: () async {
            final res = await Navigator.push<LatLng>(
                context,
                MaterialPageRoute(
                    builder: (_) => const MapPickerPage(title: 'Lieu de départ')));
            if (res != null) {
              setState(() {
                _departCoords = res;
                _departController.text = '${res.latitude}, ${res.longitude}';
              });
            }
          },
        ),
        const SizedBox(height: 24),
        _buildAddressField(
          label: 'Destination',
          nomLabel: 'Nom du destinataire',
          nomController: _arriveeNomController,
          controller: _arriveeController,
          telController: _arriveeTelController,
          isDepart: false,
          onMapPick: () async {
            final res = await Navigator.push<LatLng>(
                context,
                MaterialPageRoute(
                    builder: (_) => const MapPickerPage(title: 'Lieu d\'arrivée')));
            if (res != null) {
              setState(() {
                _arriveeCoords = res;
                _arriveeController.text = '${res.latitude}, ${res.longitude}';
              });
            }
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Détails du colis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _natureController,
          decoration: InputDecoration(
            labelText: 'Nature du colis (ex: Documents)',
            filled: true,
            fillColor: const Color(0xFFF1F1F1),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        Text('Poids: ${_poids.toStringAsFixed(1)} kg'),
        Slider(
          min: 1,
          max: 20,
          divisions: 38,
          value: _poids,
          onChanged: (value) {
            setState(() => _poids = value);
          },
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Livraison urgente'),
          value: _urgent,
          onChanged: (val) {
            setState(() => _urgent = val);
          },
        ),
        SwitchListTile(
          title: const Text('Livraison de nuit'),
          value: _nuit,
          onChanged: (val) {
            setState(() => _nuit = val);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _modePaiement,
          decoration: InputDecoration(
            labelText: 'Mode de paiement',
            filled: true,
            fillColor: const Color(0xFFF1F1F1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'cash', child: Text('Cash')),
            DropdownMenuItem(value: 'mobile_money', child: Text('Mobile Money')),
          ],
          onChanged: (val) {
            setState(() => _modePaiement = val!);
          },
        ),
      ],
    );
  }

  Widget _buildAddressField(
      {required String label,
        required String nomLabel,
        required TextEditingController nomController,
        required TextEditingController controller,
        required TextEditingController telController,
        required VoidCallback onMapPick,
        required bool isDepart}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: nomController,
          decoration: InputDecoration(
            hintText: nomLabel,
            filled: true,
            fillColor: const Color(0xFFF1F1F1),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: (val) {
            if (val.length > 5) {
              setState(() {
                if (isDepart) {
                  _departCoords ??= const LatLng(6.3654, 2.4394);
                } else {
                  _arriveeCoords ??= const LatLng(6.3700, 2.4450);
                }
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Adresse',
            suffixIcon: IconButton(
                icon: const Icon(Icons.map, color: AppColors.primary),
                onPressed: onMapPick),
            filled: true,
            fillColor: const Color(0xFFF1F1F1),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: telController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Téléphone de contact',
            prefixIcon: const Icon(Icons.phone, size: 20),
            filled: true,
            fillColor: const Color(0xFFF1F1F1),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildStepVehicule() {
    final vehiculesState = ref.watch(vehiculeListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quel véhicule ?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
        const SizedBox(height: 32),
        if (vehiculesState.isLoading) const Center(child: CircularProgressIndicator())
        else if (vehiculesState.error != null) Center(child: Text(vehiculesState.error!.displayMessage))
        else ...vehiculesState.items.map((v) => _VehiculeCard(
            vehicule: v,
            isSelected: _selectedVehicule?.id == v.id,
            onTap: () => setState(() => _selectedVehicule = v),
          )),
      ],
    );
  }

  Widget _buildStepSummary() {
    if (_estimation == null) return const SizedBox();
    final details = _estimation!['details'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Détails paiement', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mode actif', style: TextStyle(color: AppColors.info, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(_selectedMode == 'express' ? 'Livraison Express' : 'Point ILLICO', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              _PriceRow(label: 'Frais de base', value: '${details['tarifBase']} XOF'),
              _PriceRow(label: 'Distance estimée', value: '${details['coutKm']} XOF'),
              _PriceRow(label: 'Frais de zone', value: '${details['supplementZone']} XOF'),
              if ((details['supplementUrgent'] ?? 0) > 0) _PriceRow(label: 'Major Urgence', value: '${details['supplementUrgent']} XOF'),
              const Divider(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Résumé de la livraison', style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    Text('Départ: ${_departNomController.text} - ${_departController.text} (${_departTelController.text})'),
                    Text('Arrivée: ${_arriveeNomController.text} - ${_arriveeController.text} (${_arriveeTelController.text})'),
                    const SizedBox(height: 8),
                    Text('Véhicule: ${_selectedVehicule?.type ?? ''}'),
                    Text('Mode: ${_selectedMode == 'express' ? 'Express' : 'Point ILLICO'}'),
                    Text('Nature: ${_natureController.text}'),
                    const SizedBox(height: 8),
                    Text('Poids: $_poids kg'),
                    Text('Paiement: $_modePaiement'),
                    const SizedBox(height: 8),
                    Text('Urgent: ${_urgent ? 'Oui' : 'Non'}'),
                    Text('Nuit: ${_nuit ? 'Oui' : 'Non'}'),
                  ],
                ),
              ),
              _PriceRow(label: 'Total estimé', value: '${_estimation!['prixEstime']} XOF', isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    bool canContinue = false;
    String label = 'Continuer';
    VoidCallback? onPressed;

    if (_currentStep == 0 && _selectedMode != null) {
      canContinue = true;
      onPressed = () => setState(() => _currentStep = 1);
    } else if (_currentStep == 1 &&
        _departNomController.text.isNotEmpty &&
        _departController.text.isNotEmpty &&
        _departTelController.text.isNotEmpty &&
        _arriveeNomController.text.isNotEmpty &&
        _arriveeController.text.isNotEmpty &&
        _arriveeTelController.text.isNotEmpty &&
        _natureController.text.isNotEmpty) {
      canContinue = true;
      onPressed = () => setState(() => _currentStep = 2);
    } else if (_currentStep == 2 && _selectedVehicule != null) {
      canContinue = true;
      label = 'Voir l\'estimation';
      onPressed = _getEstimation;
    } else if (_currentStep == 3) {
      canContinue = true;
      label = 'Confirmer la commande';
      onPressed = _createLivraison;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E5E5)))),
      child: LoadingButton(
        onPressed: canContinue ? onPressed : null,
        label: label,
        isLoading: _isEstimating || _isCreating,
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title, subtitle, footer, badgeText;
  final Color badgeColor, iconColor;
  final Color? borderColor;
  final bool isSelected;
  final VoidCallback onTap;
  const _ModeCard({required this.title, required this.subtitle, required this.footer, required this.badgeText, required this.badgeColor, required this.iconColor, this.borderColor, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: isSelected ? (borderColor ?? AppColors.primary) : Colors.grey.withOpacity(0.2), width: 2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(10))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)), child: Text(badgeText, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Text(footer, style: TextStyle(color: borderColor ?? AppColors.primary, fontSize: 13, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _VehiculeCard extends StatelessWidget {
  final VehiculeEntity vehicule;
  final bool isSelected;
  final VoidCallback onTap;
  const _VehiculeCard({required this.vehicule, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isSelected ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2)),
        child: Row(
          children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.directions_bike, color: isSelected ? AppColors.primary : Colors.grey)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(vehicule.type.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(vehicule.description ?? '', style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ])),
            Text('${vehicule.tarifBase} XOF', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isTotal;
  const _PriceRow({required this.label, required this.value, this.isTotal = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600)),
        Text(value, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600)),
      ]),
    );
  }
}
