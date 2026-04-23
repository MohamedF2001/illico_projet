import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng initialCenter;
  final String title;

  const MapPickerPage({
    super.key,
    this.initialCenter = const LatLng(6.3654, 2.4394), // Cotonou
    required this.title,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng _currentCenter;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialCenter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context, _currentCenter),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.initialCenter,
              initialZoom: 15,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture && pos.center != null) {
                  setState(() => _currentCenter = pos.center!);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.illico.delivery',
              ),
            ],
          ),
          const Center(
            child: Icon(
              Icons.location_pin,
              size: 40,
              color: Colors.red,
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _currentCenter),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Confirmer cette position'),
            ),
          ),
        ],
      ),
    );
  }
}
