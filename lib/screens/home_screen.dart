import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickCSV(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      Navigator.pushNamed(context, '/open_csv', arguments: filePath);
    }
  }

  Future<void> _createNewCSV(BuildContext context) async {
    Navigator.pushNamed(context, '/create_csv');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // 📌 Contenedor principal con la "carpeta detrás"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Stack(
              children: [
                // Fondo de la "carpeta"
                Positioned(
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                // Tarjeta roja principal con el texto
                Container(
                  width: double.infinity, // 👈 Se ajusta al ancho disponible
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.arrow_outward, color: Colors.white, size: 42),
                          SizedBox(width: 10),
                          Expanded( // 👈 Envuelve el texto en Expanded
                            child: Text(
                              'CSV File Viewer',
                              overflow: TextOverflow.ellipsis, // 👈 Corta el texto si es demasiado largo
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'Gestiona archivos CSV de forma sencilla. Abre, crea, edita y actualiza archivos CSV de manera rápida y eficiente.',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 70),

          // 📌 Botones "Abrir" y "Crear" con efecto de "carpeta"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButtonWithFolder(
                label: "Abrir",
                icon: Icons.folder_open,
                onPressed: () => _pickCSV(context),
              ),
              const SizedBox(width: 90),
              _buildButtonWithFolder(
                label: "Crear",
                icon: Icons.edit,
                onPressed: () => _createNewCSV(context),
              ),
            ],
          ),

          const SizedBox(height: 60),

// 📌 Ilustración centrada con margen superior en porcentaje
          SizedBox(
            height: 270,
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02), // 5% de la altura de la pantalla
              child: Image.asset(
                'assets/illustration.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const Spacer(),


          // 📌 Footer con derechos de autor
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05), // 5% de la pantalla
            child: const Text(
              "© Luis Imaicela 2025",
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 Widget para los botones con efecto de "carpeta" con animación
  Widget _buildButtonWithFolder({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        double scale = 1.0;

        return GestureDetector(
          onTapDown: (_) {
            setState(() => scale = 0.8); // Reduce el tamaño al presionar
          },
          onTapUp: (_) {
            setState(() => scale = 1.0); // Vuelve al tamaño original al soltar
            Future.delayed(const Duration(milliseconds: 400), onPressed); // Ejecuta la acción del botón con un ligero retraso
          },
          onTapCancel: () {
            setState(() => scale = 1.0); // Si se cancela la pulsación, vuelve al tamaño original
          },
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: scale),
            duration: const Duration(milliseconds: 100),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 📌 Parte superior de la "carpeta" alineada a la derecha del botón
                    Positioned(
                      right: 0, // Alineado al borde derecho del botón
                      top: -15, // Posicionado justo arriba del botón
                      child: Container(
                        height: 40,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),

                    // 📌 Botón principal
                    ElevatedButton.icon(
                      onPressed: onPressed,
                      icon: Icon(icon, color: Colors.white, size: 28), // Icono más grande
                      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)), // Texto más grande
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
