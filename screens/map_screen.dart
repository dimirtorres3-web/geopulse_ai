import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import '../services/auth_service.dart';
import '../services/ai_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(0, 0);
  bool _isLoading = true;
  final AIService _aiService = AIService();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    }
  }

  Future<void> _capturarYAnalizarBache() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final controller = CameraController(cameras.first, ResolutionPreset.medium);
      await controller.initialize();
      
      final XFile image = await controller.takePicture();
      final Uint8List imageBytes = await image.readAsBytes();

      if (!mounted) return;
      _mostrarAlertaProcesando();

      final resultadoIA = await _aiService.analizarInfraestructura(imageBytes);

      if (!mounted) return;
      Navigator.pop(context); // Cierra pantalla de carga

      _mostrarResultadoFiltro(resultadoIA);
    } catch (e) {
      print("Error al capturar bache: \$e");
    }
  }

  void _mostrarAlertaProcesando() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Magi IA analizando infraestructura..."),
          ],
        ),
      ),
    );
  }

  void _mostrarResultadoFiltro(Map<String, dynamic> datos) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.blueAccent, size: 30),
                const SizedBox(width: 10),
                Text("Reporte de IA: \${datos['tipo']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 25),
            Text("🚶 Tránsito Peatonal Común: \${datos['peaton']}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("♿ Tránsito Movilidad Reducida: \${datos['movilidad']}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green),
              onPressed: () => Navigator.pop(context),
              child: const Text("SUBIR REPORTE A GEOPULSE MAPS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoPulse AI Maps', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => AuthService().signOut(),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 16),
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('REPORTAR OBSTÁCULO / BACHE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: _capturarYAnalizarBache,
                  ),
                ),
              ],
            ),
    );
  }
}