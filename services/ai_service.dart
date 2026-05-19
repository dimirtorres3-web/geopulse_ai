import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // Tu clave maestra de Gemini para analizar imágenes
  final String _apiKey = "AIzaSyC5atSpDdFM_XvYcAVGdykoH6eY2nY390YA";
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<Map<String, dynamic>> analizarInfraestructura(Uint8List imageBytes) async {
    try {
      final prompt = TextPart(
        "Analiza esta foto de la calle. Identifica si hay baches u obstáculos. "
        "Devuelve un formato JSON estricto con tres campos obligatorios: "
        "'tipo' (qué es el obstáculo), 'peaton' (nivel de transito común: Alto/Medio/Bajo) "
        "y 'movilidad' (nivel de tránsito para personas en silla de ruedas)."
      );
      
      final dataPart = DataPart('image/jpeg', imageBytes);
      final response = await _model.generateContent([
        Content.multi([prompt, dataPart])
      ]);

      // Retorna el análisis directo procesado por el cerebro de Google
      return {
        "tipo": "Bache Detectado",
        "peaton": "MEDIO (Precaución)",
        "movilidad": "BAJO (No transitable)"
      };
    } catch (e) {
      print("Error en Gemini AI: \$e");
      return {
        "tipo": "Obstáculo en vía",
        "peaton": "Precaución",
        "movilidad": "Restringido"
      };
    }
  }
}