import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../providers/livreur_provider.dart';

class LivreurMapPage extends ConsumerStatefulWidget {
  const LivreurMapPage({super.key});

  @override
  ConsumerState<LivreurMapPage> createState() => _LivreurMapPageState();
}

class _LivreurMapPageState extends ConsumerState<LivreurMapPage> {
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  Future<void> _updateLocation() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _isError = false;
    });

    try {
      // 1. Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Les permissions de localisation sont refusées.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Les permissions sont refusées de façon permanente.';
      }

      // 2. Obtenir la position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Envoyer à l'API via le notifier
      final notifier = ref.read(missionsProvider.notifier);
      final result = await notifier.ds.updatePosition([position.longitude, position.latitude]);

      result.fold(
        (f) => throw f.displayMessage,
        (_) {
          setState(() {
            _message = 'Position mise à jour : ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
            _isError = false;
          });
        },
      );

    } catch (e) {
      setState(() {
        _message = e.toString();
        _isError = true;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Position GPS'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Visibilité en Temps Réel',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Mettez à jour votre position pour permettre aux clients de suivre leur livraison en direct.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),
              if (_message != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isError ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isError ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    _message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isError ? Colors.red : Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _updateLocation,
                  icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.refresh),
                  label: Text(_isLoading ? 'Mise à jour...' : 'Mettre à jour ma position'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
